#!/usr/bin/env python3
"""
List all the files in a bucket.

Configuration

export S3_LIST_ALL_AWS_ID='__your_id__'
export S3_LIST_ALL_AWS_SECRET='__your_secret__'

Usage:

S3_LIST_ALL_AWS_ID="$AK__AWS_ACCESS_KEY_ID" \
  S3_LIST_ALL_AWS_SECRET="$AK__AWS_SECRET_KEY" \
  s3_list_all_objects.py \
  kortina-private \
  > ~/gd/__s3/s3-kortina-private.txt

S3_LIST_ALL_AWS_ID="$SQ__AWS_ACCESS_KEY_ID" \
  S3_LIST_ALL_AWS_SECRET="$SQ__AWS_SECRET_KEY" \
  s3_list_all_objects.py \
  sq-us-east-1 \
  > ~/gd/__s3/s3-sq-us-east-1.txt

"""


import argparse
import os

import boto3


def _get_required_env_var(var):
    val = os.environ.get(var)
    if val in [None, ""]:
        raise NameError(f"Required env var {var} was not set.")
    return val


def get_all_s3_objects(s3_client, **base_kwargs):
    continuation_token = None
    while True:
        list_kwargs = dict(MaxKeys=1000, **base_kwargs)
        if continuation_token:
            list_kwargs["ContinuationToken"] = continuation_token
        response = s3_client.list_objects_v2(**list_kwargs)
        yield from response.get("Contents", [])
        if not response.get("IsTruncated"):  # At the end of the list?
            break
        continuation_token = response.get("NextContinuationToken")


if __name__ == "__main__":
    parser = argparse.ArgumentParser("python s3_list_all_objects.py")
    parser.add_argument(
        "bucket",
        type=str,
        help="Bucket to list objects from.",
    )
    parser.add_argument(
        "--prefix",
        default=None,
        type=str,
        help="Prefix to match.",
    )
    args = parser.parse_args()
    bucket = args.bucket
    prefix = args.prefix or ""

    aws_id = _get_required_env_var("S3_LIST_ALL_AWS_ID")
    aws_secret = _get_required_env_var("S3_LIST_ALL_AWS_SECRET")
    s3_client = boto3.client("s3", aws_access_key_id=aws_id, aws_secret_access_key=aws_secret)

    for file in get_all_s3_objects(s3_client, Bucket=bucket, Prefix=prefix):
        print(file["Key"])
