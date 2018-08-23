#!/usr/bin/env python

import argparse
from datetime import datetime
import json


def parse_history(browser_history):
    with open(browser_history) as f:
        data = json.load(f)['Browser History']
        for page in data:
            ts = page['time_usec'] / 1000 / 1000  # us to s
            utct = datetime.utcfromtimestamp(ts)
            print(u'{0}\t{1}\t{2}'.format(
                  utct.strftime('%Y-%m-%d'),
                  page['title'],
                  page['url'])).encode('utf-8')


if __name__ == "__main__":
    parser = argparse.ArgumentParser("python taktou_chrome.py")
    parser.add_argument('-f', '--file', required=True, dest="file", type=str,
                        help="Path to file to process.")
    args = parser.parse_args()
    parse_history(args.file)
