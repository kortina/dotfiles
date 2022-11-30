#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
from typing import List


def main() -> None:
    parser = argparse.ArgumentParser("python av_transcribe.py [directory]")
    # parser.add_argument("--verbose", "-v", default=0, action="count")
    parser.add_argument(
        "directory", type=str, help="directory containing av media files"
    )
    known_args, whisper_args = parser.parse_known_args()

    # pass additional arguments (--model --language etc) on to whisper
    S.WHISPER_ARGS = whisper_args
    directory_path = os.path.abspath(known_args.directory)
    print(f"# TRANSCRIBING MEDIA AT:\n{directory_path}")
    for subdir, dirs, files in os.walk(directory_path):
        for filename in files:
            filepath = os.path.join(subdir, filename)
            av = AV(filepath)
            av.transcribe()


class S:
    # default settings
    # override with cli args
    DEBUG = True
    MODEL = "small"
    REGEX_AV = re.compile(r"\.(braw|mov|mp3|mp4)$", re.I)
    WHISPER_ARGS: List[str] = []


class AV:
    def __init__(self, path: str):
        self.path = path
        self.relpath = os.path.relpath(path, os.curdir)
        self.dirname = os.path.dirname(path)
        self.basename = os.path.basename(path)

    def _skip(self, msg: str) -> None:
        print(f"SKIP...... {self.relpath}: {msg}")

    def _scribe(self) -> None:
        print(f"TRANSCRIBE {self.relpath}")
        cmd = ["whisper", self.basename] + S.WHISPER_ARGS
        run_cmd(cmd, self.dirname)

    def transcribe(self) -> None:
        if not self.matches_av_regex():
            return
        if self.already_transcribed():
            return self._skip("srt exists")
        self._scribe()

    def matches_av_regex(self) -> (re.Match[str] | None):
        return re.search(S.REGEX_AV, self.path)

    @property
    def srt(self) -> str:
        return f"{self.path}.srt"

    @property
    def txt(self) -> str:
        return f"{self.path}.txt"

    @property
    def vtt(self) -> str:
        return f"{self.path}.vtt"

    def already_transcribed(self) -> bool:
        return os.path.exists(self.srt)


def run_cmd(cmd_args: list, cwd=None) -> subprocess.CompletedProcess[bytes]:
    cmd = " ".join(cmd_args)
    if S.DEBUG:
        print(f"RUNNING:\n{cmd}")
    return subprocess.run(cmd_args, check=True, cwd=cwd)


# def log(anything):
#     if S.DEBUG:
#         print(f"{anything}")


# represents a AVFile file (markdown, fountain)
# and stats about it (number of lines, words, etc)


if __name__ == "__main__":
    main()
