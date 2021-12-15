#!/usr/bin/env python3
import argparse
import datetime
import os
import re
import shutil
import subprocess


DEBUG = True


def run_cmd(cmd_args: list):
    cmd = " ".join(cmd_args)
    if DEBUG:
        print(f"running:\n{cmd}")
    subprocess.run(cmd_args)


def main():
    parser = argparse.ArgumentParser(
        description="""Given a file, such as,
        my_screenplay.highland
        extract the plaintext fountain file to:
        my_screenplay.highland.fountain
    """
    )
    parser.add_argument(
        "file",
        type=str,
        help="file",
        default=None,
    )
    args = parser.parse_args()
    f_highland = args.file
    if not re.search(r"\.highland$", f_highland):
        raise argparse.ArgumentError(
            args.file, "does not appear to be a .highland file."
        )

    base_highland = os.path.basename(f_highland)
    abs_f_highland = os.path.abspath(f_highland)
    abs_dir_highland = os.path.dirname(abs_f_highland)

    abs_dir_tmp = "/tmp/highland"
    # make the tmp directory
    os.makedirs(abs_dir_tmp)

    f_tmp_highland = os.path.join(abs_dir_tmp, base_highland)

    # copy highland file to tmp
    cmd_args = ["cp", abs_f_highland, f_tmp_highland]
    run_cmd(cmd_args)

    # unzip in tmp
    cmd_args = ["unzip", f_tmp_highland, "-d", abs_dir_tmp]
    run_cmd(cmd_args)

    # copy the plaintext file to original directory
    f_textbundle = re.sub(r"(\.highland)", ".textbundle", base_highland)
    abs_path_txt = os.path.join(abs_dir_tmp, f_textbundle, "text.fountain")

    f_fountain = f"{base_highland}.x.fountain"
    abs_f_fountain = os.path.join(abs_dir_highland, f_fountain)

    cmd_args = ["cp", abs_path_txt, abs_f_fountain]
    run_cmd(cmd_args)

    # cleanup tmp directory
    shutil.rmtree(abs_dir_tmp)

    # f_abs_filename = os.path.join(abs_path, f_filename)

    # cmd_args = ["cp", f_highland, f_filename]
    # cmd = " ".join(cmd_args)
    # print(f"running {cmd}")
    # print("----")
    # print(f"{f_filename}")


if __name__ == "__main__":
    main()
