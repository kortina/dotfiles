#!/usr/bin/env python3

import argparse

# import subprocess
import sys


# def get_clipboard():
#     return subprocess.check_output(["pbpaste"], universal_newlines=True).replace(
#         "\n", ""
#     )


# def copy_to_clipboard(s):
#     process = subprocess.Popen(
#         "pbcopy", env={"LANG": "en_US.UTF-8"}, stdin=subprocess.PIPE
#     )
#     process.communicate(s.encode("utf-8"))


# def notify_osx(title, text):
#     s = '''display notification "{}" with title "{}"'''.format(text, title)
#     process = subprocess.Popen(
#         ["osascript", "-"], env={"LANG": "en_US.UTF-8"}, stdin=subprocess.PIPE
#     )
#     process.communicate(s.encode("utf-8"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser("python newlines_to_tabs.py")
    parser.add_argument(
        "--cols",
        dest="cols",
        # default=None,
        type=int,
        help=("Number of cols (retain every n-th newlines, convert others to tabs)"),
    )
    args = parser.parse_args()
    cols = args.cols
    i = 0
    no_newline = ""
    for line in sys.stdin.read().split("\n"):
        i = i + 1
        # replace newlines and tabs from input, to be safe:
        print(line.replace("\n", "").replace("\t", " "), end=no_newline)
        if i % cols == 0:
            print("\n", end=no_newline)
        else:
            print("\t", end=no_newline)

    # if args.copy_to_clipboard:
    #     copy_to_clipboard(short)
    #     text = f"{text} copied to clipboard."
    #     notify_osx(f"newlines_to_tabs.py {url}", text)
