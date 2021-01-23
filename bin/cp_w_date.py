#!/usr/bin/env python3
import argparse
import datetime
import os
import subprocess


def main():
    parser = argparse.ArgumentParser("cp_w_date.py")
    parser.add_argument(
        "file", type=str, help="file", default=None,
    )
    args = parser.parse_args()
    old_filename = args.file
    root, ext = os.path.splitext(old_filename)
    dt = datetime.datetime.now().strftime("%Y-%m-%d--%H-%M")
    new_root = "--".join([root, dt])
    new_filename = "".join([new_root, ext])

    cmd_args = ["cp", old_filename, new_filename]
    cmd = " ".join(cmd_args)
    print(f"running {cmd}")
    subprocess.run(cmd_args)


if __name__ == "__main__":
    main()
