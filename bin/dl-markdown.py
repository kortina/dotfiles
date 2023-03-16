#!/usr/bin/env python3
# This is a light wrapper around https://github.com/ttscoff/gather-cli
# It does not overwrite the file if it already exists.
# And it appends the current date / time of download as a comment to the end of the file.
import argparse
import datetime
import os
import re
import subprocess


DEBUG = True


def run(cmd_args: list[str]) -> str:
    if DEBUG:
        cmd = " ".join(cmd_args)
        print("------------")
        print("running:")
        print(cmd)
    out = subprocess.run(cmd_args, capture_output=True, text=True).stdout
    if DEBUG:
        print(out)
        print("------------")
    return out


def main():
    HOME = os.environ.get("HOME")
    parser = argparse.ArgumentParser(
        description="""Download and save markdown for the URL in the clipboard using gather.
    """
    )
    # parser.add_argument(
    #     "file",
    #     type=str,
    #     help="file",
    #     default=None,
    # )
    # args = parser.parse_args()
    parser.parse_args()

    filename = "%slug.md"
    tmp_path = f"{HOME}/tmp/{filename}"
    final_dir = f"{HOME}/gd/Books-Papers-Screenplays/_gather/"

    cmd_args = ["gather", "-p", "--metadata-yaml", "-f", tmp_path]
    out = run(cmd_args)

    # grab the actual tmp_path since filename uses %s
    m = re.search(r"Saved to file: ([\S]+)$", out)
    fn = None
    if m:
        tmp_path = m.group(1)
        # grab the actual markdown filename off th tmp_path since filename uses %s
        fn = re.search(r"([^\/]+$)", tmp_path).group(1)
        # only move to final destination if target file does not already exist
        cmd_args = ["mv", "-n", tmp_path, final_dir]
        run(cmd_args)
    else:
        print("[ERROR] No tmp file........")
        raise SystemExit(1)

    # cleanup tmp file
    if os.path.exists(tmp_path):
        os.remove(tmp_path)

    # append downloaded date as comment to end of file
    dt = datetime.datetime.now().strftime("%Y-%m-%d--%H-%M")
    msg = f"\n<!-- download-dt: {dt} -->"
    with open(os.path.join(final_dir, fn), "a") as f:
        f.write(msg)


if __name__ == "__main__":
    main()
