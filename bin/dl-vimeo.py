#!/usr/bin/env python3
# -*- encoding: utf-8
"""
Simple cli wrapper for:
https://github.com/yashrathi-git/vimeo_downloader

pip install vimeo_downloader
"""

import argparse
from vimeo_downloader import Vimeo


def main():
    parser = argparse.ArgumentParser("dl-vimeo.py [vimeo_url]")
    parser.add_argument(
        "vimeo_url",
        type=str,
        help="URL of youtube vid",
    )
    args = parser.parse_args()
    download_vimeo(args.vimeo_url)


def download_vimeo(url):
    v = Vimeo(url=url)
    best_stream = v.best_stream
    mp4_url = best_stream.direct_url
    # title = best_stream.title
    best_stream.download()


if __name__ == "__main__":
    main()
