#!/usr/bin/env python3
import datetime
import git
import os
import subprocess


# git clone git@github.com:kortina/_notebook.git stats_for__notebook
# git log --pretty="format:%h @ %ai" --reverse | head -1
# 84fcd92 @ 2021-01-18 17:04:38 -0800


class S:
    # default settings
    # override with cli args
    DEBUG = False
    ORIGIN_URL = "git@github.com:kortina/_notebook.git"
    CHECKOUT_DIR = "/Users/kortina/src/stats_for__notebook"
    FIRST_D = "2021-02-01"
    LAST_D = "2022-01-01"


def run_cmd(cmd_args: list, cwd: str | None):
    cmd = " ".join(cmd_args)
    if S.DEBUG:
        print(f"running:\n{cmd}")

    cwd = None
    if repo_exists():
        cwd = S.CHECKOUT_DIR

    subprocess.run(cmd_args, check=True, cwd=cwd)


def repo_exists():
    return os.path.isdir(S.CHECKOUT_DIR)


def r():
    if repo_exists():
        return git.Repo.init(S.CHECKOUT_DIR)
    else:
        return git.Repo.clone_from(S.ORIGIN_URL, S.CHECKOUT_DIR, branch="master")


def datetime_for_commit(commit):
    return datetime.datetime.fromtimestamp(commit.time[0])


def datetime_from_string(d: str):
    return datetime.datetime


# https://stackoverflow.com/a/7380905/382912
# bisect with lambda:
# https://docs.python.org/3/library/bisect.html

# iterative_lev (edit distance)
# https://python-course.eu/applications-python/levenshtein-distance.php

# % character similarity


def first_commit_date():
    repo = r()
    heads = repo.heads
    master = heads.master
    log = master.log()
    first_commit = log[0]
    return datetime_for_commit(first_commit)


def main():
    first_commit_date()


if __name__ == "__main__":
    main()
