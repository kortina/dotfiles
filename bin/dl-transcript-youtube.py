#!/usr/bin/env python3
# -*- encoding: utf-8
"""
Best-effort clean up of downloaded YouTube .vtt subtitle files.
via:
https://github.com/alexwlchan/junkdrawer/blob/d8ee4dee1b89181d114500b6e2d69a48e2a0e9c1/services/youtube/vtt2txt.py
https://alexwlchan.net/2019/04/getting-a-transcript-of-a-talk-from-youtube/
"""

import argparse
import glob
import itertools
import os
import re
import subprocess


def main():
    parser = argparse.ArgumentParser("dl-transcript-youtube.py [youtube_url]")
    parser.add_argument(
        "youtube_url",
        type=str,
        help="URL of youtube vid",
    )
    args = parser.parse_args()
    download_and_cleanup_transcript(args.youtube_url)


def download_and_cleanup_transcript(url):
    # youtube-dl --write-auto-sub --skip-download
    # cmd_args = ["youtube-dl", "--write-auto-sub", "--skip-download", "-o", fn_base, url]
    cmd_args = [
        "yt-dlp",
        "--write-subs",
        "--sub-langs",
        "en.*",
        "--sub-format",
        "vtt",
        "--skip-download",
        url,
    ]
    cmd = " ".join(cmd_args)
    print(f"running {cmd}")
    subprocess.run(cmd_args)

    # get the name of the most recently created file in the current directory
    # with the extension .vtt
    fn = sorted(glob.glob("*.vtt"), key=os.path.getmtime)[-1]

    # this part appears to be broken:
    cleanup_transcript(fn)


def cleanup_transcript(fn):
    data = open(fn).read()
    data, _ = re.subn(
        r"\d{2}:\d{2}:\d{2}\.\d{3} \-\-> \d{2}:\d{2}:\d{2}\.\d{3} align:start position:0%\n",
        "",
        data,
    )

    # And the color changes, e.g.
    #
    #     <c.colorE5E5E5>
    #
    data, _ = re.subn(r"<c\.color[0-9A-Z]{6}>", "", data)

    # And any other timestamps, typically something like:
    #
    #    </c><00:00:00,539><c>
    #
    # with optional closing/opening tags.
    data, _ = re.subn(r"(?:</c>)?(?:<\d{2}:\d{2}:\d{2}\.\d{3}>)?(?:<c>)?", "", data)

    # 00:00:03,500 --> 00:00:03,510
    data, _ = re.subn(
        r"\d{2}:\d{2}:\d{2}\.\d{3} \-\-> \d{2}:\d{2}:\d{2}\.\d{3}\n", "", data
    )

    # Now get the distinct lines.
    data = [line.strip() for line in data.splitlines() if line.strip()]

    for line, _ in itertools.groupby(data):
        print(line)

    # with open(sys.argv[1] + '.txt', 'w') as outfile:
    #     outfile.write('\n'.join(dedupe_components))
    #
    # print(sys.argv[1] + '.txt')


if __name__ == "__main__":
    main()
