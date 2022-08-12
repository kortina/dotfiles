#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
import tinify


class Settings:
    debug = False


def run_cmd(cmd_args: list, cwd=None):
    cmd = " ".join(cmd_args)
    if Settings.debug:
        print(f"running:\n{cmd}")
    subprocess.run(cmd_args, check=True, cwd=cwd)


def main():
    parser = argparse.ArgumentParser(
        description="""Given an image file, such as,
            img.png
        convert to jpg and make tiny:
            img.tiny.jpg
    """
    )
    parser.add_argument(
        "--debug",
        dest="debug",
        action="store_true",
        help="Set debug mode output.",
    )
    parser.add_argument(
        "file",
        type=str,
        help="input img file",
        default=None,
    )
    args = parser.parse_args()
    f_source = args.file
    is_jpg = False
    rx_jpg = re.compile(r"\.(jpg|jpeg)$", re.I)

    if args.debug:
        Settings.debug = True

    if not os.path.isfile(f_source):
        parser.error(f"file '{args.file}' does not exist.")

    is_jpg = True if re.search(rx_jpg, f_source) else False

    if re.search(r"\.tiny\.jpg$", f_source):
        parser.error(f"file {args.file}' is already tiny jpg")

    source_fn = os.path.basename(f_source)

    source_abs_path = os.path.abspath(f_source)
    cwd = os.path.dirname(source_abs_path)

    no_ext_fn = re.sub(r"(\.[^\.]+)$", "", source_fn)
    jpg_fn = f"{no_ext_fn}.jpg"
    tiny_fn = f"{no_ext_fn}.tiny.jpg"

    if not is_jpg:
        # convert to jpg with imagemagick
        cmd_args = ["convert", source_fn, jpg_fn]
        run_cmd(cmd_args, cwd)
        source_fn = jpg_fn

    fn_tiny_full = os.path.join(cwd, tiny_fn)

    if os.path.isfile(fn_tiny_full):
        parser.error(f"File already exists: {fn_tiny_full}")

    tinify.key = os.environ.get("TINY_JPG_API_KEY")
    source = tinify.from_file(source_fn)
    source.to_file(tiny_fn)


if __name__ == "__main__":
    main()
