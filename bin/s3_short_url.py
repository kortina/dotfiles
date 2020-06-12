#!/usr/bin/env python3
# Very basic URL shortener built with:
# - python3
# - s3
# - cloudfront
# - route53
#
# Configuration
#
# export S3_SHORT_URL_DOMAIN='custom.domain'
# export S3_SHORT_URL_AWS_BUCKET='custom.domain'
# export S3_SHORT_URL_AWS_ID='__your_id__'
# export S3_SHORT_URL_AWS_SECRET='__your_secret__'
# export S3_SHORT_URL_AWS_CLOUDFRONT_DISTRIBUTION_ID='__your_dist_id__'
#
# Shorten a URL:
#   s3_short_url.py https://kortina.nyc/
#   > https://ark.dance/4HO-Kbh
#
# Shorten a URL with custom key:
#   s3_short_url.py --key=kortina https://kortina.nyc/
#   > https://ark.dance/kortina
#
# Shorten a URL with custom key, replace if exists
#   s3_short_url.py --key=kortina --replace=1 https://kortina.nyc/?a=1
#   > https://ark.dance/kortina
#
# Shorten a URL, adding the target domain to the key
#   s3_short_url.py --prefix-key-with-domain=1 https://kortina.nyc/?a=1
#   > https://ark.dance/kortina.nyc/LOwL-2YP
#
# From and back to clipboard (this is what I have as an Alfred shortcut)
#
#   s3_short_url.py --copy-to-clipboard=true clipboard
#   > shortens the long URL in the clipboard, puts short URL in clipboard


import argparse
import boto3
from botocore.exceptions import ClientError
import os
import subprocess
import random
import time
from urllib.parse import urlparse

T_ZERO = 1586654125.0
S3_CLIENT = None
DEBUG = False


def get_clipboard():
    return subprocess.check_output(["pbpaste"], universal_newlines=True).replace(
        "\n", ""
    )


def copy_to_clipboard(s):
    process = subprocess.Popen(
        "pbcopy", env={"LANG": "en_US.UTF-8"}, stdin=subprocess.PIPE
    )
    process.communicate(s.encode("utf-8"))


def notify_osx(title, text):
    s = '''display notification "{}" with title "{}"'''.format(text, title)
    process = subprocess.Popen(
        ["osascript", "-"], env={"LANG": "en_US.UTF-8"}, stdin=subprocess.PIPE
    )
    process.communicate(s.encode("utf-8"))


# Ref _int_to_str / _str_to_int: https://ark.dance/LOjf-bbU
# Use "-"" for separator from rnd
ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"


def _int_to_str(n):
    encoded = ""
    while n > 0:
        n, r = divmod(n, len(ALPHABET))
        encoded = ALPHABET[r] + encoded
    return encoded


def _str_to_int(s):
    decoded = 0
    while len(s) > 0:
        decoded = decoded * len(ALPHABET) + ALPHABET.find(s[0])
        s = s[1:]


def _time():
    # Time will be our source of monotonically increasing unique IDs
    # which are NON-RANDOM.
    # To claim back some of the namespace, we subtract T_ZERO (the creation time of this script)
    # from the current UNIX timestamp.
    t_now = int(time.time())
    t_since_zero = t_now - int(T_ZERO)
    return t_since_zero


def _time_to_str():
    # Generate the non-random part of URL hash from the current time.
    return _int_to_str(_time())


def _rnd():
    # Generate k more random chars, to add a little bit of randomness
    k = 3
    alpha = [*"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"]
    # n = len(alpha)
    # there will be n ^ k
    # eg, when n = 62 there are 238,328 permutations of length (k) 3
    s = ""
    i = 0
    while i < k:
        s += random.choice(alpha)
        i = i + 1
    return s


def _time_based_key():
    # Return a mostly-NOT-RANDOM string based on the time
    # with a sort-of-random k-char string appended
    return f"{_time_to_str()}-{_rnd()}"


def _domain(url):
    return urlparse(url).netloc


def _prefix_key_with_domain(url, key):
    d = _domain(url)
    return f"{d}/{key}"


def _cloudfront_invalidate(key):
    # print("_cloudfront_invalidate")
    dist_id = os.environ.get("S3_SHORT_URL_AWS_CLOUDFRONT_DISTRIBUTION_ID")
    if dist_id in [None, ""]:
        return
    client = boto3.client(
        "cloudfront", aws_access_key_id=aws_id, aws_secret_access_key=aws_secret
    )
    caller_reference = f"{int(time.time())}-{key}"
    # This does seem to correctly invalidate CloudFront,
    # but I think because the redirect is a 301 my browser is still caching the original...
    response = client.create_invalidation(
        DistributionId=dist_id,
        InvalidationBatch={
            "Paths": {"Quantity": 1, "Items": [f"/{key}"]},
            "CallerReference": caller_reference,
        },
    )
    if DEBUG:
        print(response)


def _exists(bucket, key):
    client = S3_CLIENT
    try:
        response = client.head_object(Bucket=bucket, Key=key)
        return response.get("WebsiteRedirectLocation")
    except ClientError as err:
        # This Error Message is good: the key does NOT already exist
        if "Not Found" in err.response.get("Error").get("Message"):
            return None
        else:
            raise


def s3_short_url(
    url,
    bucket,
    base_url=None,
    key=None,
    replace_duplicate_key=False,
    prefix_key_with_domain=False,
):
    # generate a new short-url that redirects to `url`
    if key in [None, ""]:
        key = _time_based_key()
    else:
        # make sure we strip all chars we are not using:
        _key = ""
        alpha = [*"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"]
        for c in [*key]:
            if c in alpha:
                _key = _key + c
        key = _key
    if prefix_key_with_domain:
        key = _prefix_key_with_domain(url, key)

    client = S3_CLIENT
    existing = _exists(bucket, key)
    if existing:
        if replace_duplicate_key:
            _cloudfront_invalidate(key)
        else:
            raise ValueError(
                f"Key {key} already exists. Pass replace_duplicate_key=true to overwrite."
            )

    response = client.put_object(
        Bucket=bucket,
        ACL="public-read",
        ContentType="text/html",
        Key=key,
        WebsiteRedirectLocation=url,
    )
    if DEBUG:
        print(response)
    short = f"{base_url}{key}"
    print(short)
    return short


def _str2bool(v):
    # via: https://stackoverflow.com/a/43357954/382912
    if isinstance(v, bool):
        return v
    if v.lower() in ("yes", "true", "t", "y", "1"):
        return True
    elif v.lower() in ("no", "false", "f", "n", "0"):
        return False
    else:
        raise argparse.ArgumentTypeError("Boolean value expected.")


def _get_required_env_var(var):
    val = os.environ.get(var)
    if val in [None, ""]:
        raise NameError(f"Required env var {var} was not set.")
    return val


if __name__ == "__main__":
    parser = argparse.ArgumentParser("python s3_short_url.py")
    parser.add_argument("--verbose", "-v", default=0, action="count")
    parser.add_argument(
        "--key",
        default=None,
        type=str,
        help=(
            "Custom key for the short url, eg, /'custom' (without the slash)."
            "  If None, will generate an obfuscated NON-RANDOM unique hash."
        ),
    )
    parser.add_argument(
        "--replace",
        dest="replace_duplicate_key",
        type=_str2bool,
        default=False,
        help="If key already points to a URL, replace it. Defaults to 'false'",
    )
    parser.add_argument(
        "--prefix-key-with-domain",
        dest="prefix_key_with_domain",
        type=_str2bool,
        default=False,
        help="Add domain to key, eg, instead of /key /github.com/key - Defaults to 'false'",
    )
    # Setting up https requires some additional AWS configuration.
    # See: https://medium.com/@sbuckpesch/setup-aws-s3-static-website-hosting-using-ssl-acm-34d41d32e394
    parser.add_argument(
        "--http_urls",
        dest="http_urls",
        type=_str2bool,
        default=False,
        help="Use http: instead of https: urls. Defaults to 'false'",
    )
    parser.add_argument(
        "--copy-to-clipboard",
        dest="copy_to_clipboard",
        type=_str2bool,
        default=True,
        help="Copy new short URL to clipboard.",
    )
    parser.add_argument(
        "url",
        type=str,
        help="URL to shorten. Use special argument 'clipboard' to get the URL from the clipboard.",
    )
    args = parser.parse_args()
    url = args.url
    if url.lower().replace("'", "") == "clipboard":
        url = get_clipboard()

    # optional custom domain,
    # see: https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
    #
    # NB (1): when using CloudFront to serve domain over https,
    # in Route 53, you must set an Alias from custom.domain.
    # to your CloudFront target, not an s3 bucket target,
    # as you would normally do with website hosting on s3.
    # eg, d3ee1pbj2n8aml.cloudfront.net
    #
    # NB (2): when you setup CloudFront, the webconsole will autocomplete origins to s3 in the format:
    # custom.domain.s3.amazonaws.com
    # You **MUST** instead use the format:
    # custom.domain.s3-website-us-east-1.amazonaws.com
    domain = os.environ.get("S3_SHORT_URL_DOMAIN")
    bucket = _get_required_env_var("S3_SHORT_URL_AWS_BUCKET")
    proto = "http" if args.http_urls else "https"
    base_url = f"{proto}://s3.amazonaws.com/{bucket}/"
    if domain not in [None, ""]:
        base_url = f"{proto}://{domain}/"
    aws_id = _get_required_env_var("S3_SHORT_URL_AWS_ID")
    aws_secret = _get_required_env_var("S3_SHORT_URL_AWS_SECRET")

    S3_CLIENT = boto3.client(
        "s3", aws_access_key_id=aws_id, aws_secret_access_key=aws_secret
    )
    short = s3_short_url(
        url=url,
        bucket=bucket,
        base_url=base_url,
        key=args.key,
        replace_duplicate_key=args.replace_duplicate_key,
        prefix_key_with_domain=args.prefix_key_with_domain,
    )
    text = f"{short}"

    if args.copy_to_clipboard:
        copy_to_clipboard(short)
        text = f"{text} copied to clipboard."
    notify_osx(f"s3_short_url.py {url}", text)
