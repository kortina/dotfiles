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
    # eg, for embed: vimeo_url = 'https://player.vimeo.com/video/498617513'
    parser.add_argument(
        "vimeo_url",
        type=str,
        help="URL of youtube vid or embed.",
    )
    # eg: embedded_on = 'https://atpstar.com/plans-162.html'
    parser.add_argument(
        "--embedded-on",
        default=None,
        type=str,
        help="URL where video is embedded.",
    )
    args = parser.parse_args()
    download_vimeo(args.vimeo_url, args.embedded_on)


def download_vimeo(url, embedded_on=None):
    v = Vimeo(url, embedded_on)
    best_stream = v.best_stream
    # mp4_url = best_stream.direct_url
    # title = best_stream.title
    best_stream.download()


if __name__ == "__main__":
    main()
