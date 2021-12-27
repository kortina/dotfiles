#!/usr/bin/env python3
from bisect import bisect_left
from dataclasses import dataclass, field
import datetime
from decimal import Decimal, getcontext
import git
import os
import re
import subprocess
from typing import List, Set


# git clone git@github.com:kortina/_notebook.git stats_for__notebook
# git log --pretty="format:%h @ %ai" --reverse | head -1
# 84fcd92 @ 2021-01-18 17:04:38 -0800


class S:
    # default settings
    # override with cli args
    DEBUG = True
    ORIGIN_URL = "git@github.com:kortina/_notebook.git"
    CHECKOUT_DIR = "/Users/kortina/src/stats_for__notebook"
    FIRST_D = "2021-02-01"
    LAST_D = "2022-01-01"
    REGEX = re.compile(r"\.(fountain|md|markdown|txt)$", re.I)

    def __init__(self) -> None:
        self.files: List[Txt] = []
        self.lines_set: Set[str] = set([])


def log(anything):
    if S.DEBUG:
        print(f"{anything}")


# represents a Txt file (markdown, fountain)
# and stats about it (number of lines, words, etc)
class Txt:
    def __init__(self, filepath: str, count_on_init: int = True) -> None:
        self.filepath = filepath
        self.lines_set: Set[str] = set([])
        self.line_count: int = 0
        self.line_non_blank_count: int = 0
        self.word_count: int = 0
        if count_on_init:
            self.run_counts()

    def kind(self) -> str:
        if re.search(re.compile(r"\.(fountain)$", re.I), self.filepath):
            return "fountain"
        if re.search(re.compile(r"\.(md|markdown)$", re.I), self.filepath):
            return "markdown"
        if re.search(re.compile(r"\.(txt)$", re.I), self.filepath):
            return "txt"
        return re.sub(r"(.*)\.(^[\.]+)$", "\2", self.filepath)

    def run_counts(self):
        self.line_count = 0
        self.word_count = 0
        with open(self.filepath) as file:
            for line in file:
                self.line_count += 1
                if line.strip() != "":
                    self.line_non_blank_count += 1
                self.word_count += len(line.split())
                self.lines_set.add(line.strip())

    def filename(self) -> str:
        return self.filepath.replace(S.CHECKOUT_DIR, "")

    @classmethod
    def print_header(cls) -> List[str | int]:
        return ["name", "words", "lines", "set_lines"]

    def print_data(self) -> List[str | int]:
        return [self.filename(), self.word_count, self.line_count, len(self.lines_set)]


def run_cmd(cmd_args: list, cwd: str | None) -> None:
    cmd = " ".join(cmd_args)
    if S.DEBUG:
        print(f"running:\n{cmd}")

    subprocess.run(cmd_args, check=True, cwd=cwd)


class Repo:
    ORIGIN_NOT_SET = "ORIGIN_NOT_SET"

    def __init__(self, origin_url: str, checkout_dir: str) -> None:
        self.origin_url: str = origin_url
        self.checkout_dir: str = checkout_dir
        self.git_repo: git.Repo
        if self.repo_exists():
            self.git_repo = git.Repo.init(self.checkout_dir)
        else:
            self.git_repo = git.Repo.clone_from(
                self.origin_url, self.checkout_dir, branch="master"
            )
        # make sure local master tracks remote origin
        self.git_repo.heads.master.set_tracking_branch(
            self.git_repo.remotes.origin.refs.master
        )

        # fetch the latest from remote origin
        self.git_repo.remotes.origin.fetch()

        # checkout master
        self.git_repo.git.checkout("master")

        # submodule update --init
        for submodule in self.git_repo.submodules:
            submodule.update(init=True)

    def repo_exists(self) -> bool:
        return os.path.isdir(self.checkout_dir)

    @classmethod
    def root_repo(cls):
        return Repo(S.ORIGIN_URL, S.CHECKOUT_DIR)

    def master_commits(self):
        # return root_repo().heads.master.log()
        # return root_repo().remotes.origin.refs.master.log()
        # returns newest to oldest
        commits = list(self.git_repo.iter_commits("master"))
        # sort oldest to newest
        commits.reverse()
        return commits

    def first_commit_date(self) -> datetime.datetime:
        commits = self.master_commits()
        first_commit = commits[0]
        return datetime_for_commit(first_commit)

    # https://stackoverflow.com/a/7380905/382912
    # bisect with lambda:
    def newest_commit_before_date(self, d: str):
        # Find the newest commit that occurred before the date d
        # d: str "yyyy-mm-dd"
        # via:
        # https://docs.python.org/3/library/bisect.html
        # "Find rightmost value less than x"
        dt = datetime_from_string(d)
        print(f"finding commit before: {dt}")

        commits = self.master_commits()
        i = bisect_left(commits, x=dt, key=datetime_for_commit)
        if i:
            return commits[i - 1]
        raise ValueError

    def checkout_repo_at_date(self, d: str):
        # first do a hard reset
        self.git_repo.git.reset("--hard", "origin/master")

        # get the commit for d
        commit_at_date = self.newest_commit_before_date(d)
        log(
            f"Checking out {commit_at_date.hexsha[0:6]}"
            f" from {datetime_for_commit(commit_at_date)}"
            f" for {self.checkout_dir}"
        )
        self.git_repo.git.checkout(commit_at_date.hexsha)

        # for each submodule, check it out at the date
        for submodule in self.git_repo.submodules:
            sub_repo_path = os.path.join(self.checkout_dir, submodule.path)
            sub_repo = Repo(Repo.ORIGIN_NOT_SET, sub_repo_path)
            sub_repo.checkout_repo_at_date(d)


def datetime_for_commit(commit) -> datetime.datetime:
    # t = commit.time[0]
    t = commit.authored_date
    d = datetime.datetime.fromtimestamp(t)
    return d


def datetime_from_string(d: str) -> datetime.datetime:
    # Given a string "yyyy-mm-dd" return a datetime object
    yyyy, mm, dd = d.split("-")
    return datetime.datetime(int(yyyy), int(mm), int(dd), 0, 0)


# iterative_lev (edit distance)
# https://python-course.eu/applications-python/levenshtein-distance.php

# % character similarity


def txt_files() -> List[Txt]:
    _files = []
    for subdir, dirs, files in os.walk(S.CHECKOUT_DIR):
        for filename in files:
            filepath = os.path.join(subdir, filename)
            if re.search(S.REGEX, filepath):
                _files.append(Txt(filepath))
                print(filepath.replace("/Users/kortina/src/stats_for__notebook/", ""))
    return _files


@dataclass
class Summary:
    kind: str
    line_count: int = 0
    line_non_blank_count: int = 0
    lines_set: Set[str] = field(default_factory=set)
    word_count: int = 0
    file_count: int = 0


K_ALL = "ALL"


def print_summary() -> None:
    summaries = {K_ALL: Summary(kind=K_ALL)}
    data: List[List[str | int]] = [Txt.print_header()]

    for t in txt_files():
        data.append(t.print_data())
        for k in [K_ALL, t.kind()]:
            if k not in summaries:
                summaries[k] = Summary(kind=k)

            summaries[k].file_count += 1
            summaries[k].line_count += t.line_count
            summaries[k].line_non_blank_count += t.line_non_blank_count
            summaries[k].word_count += t.word_count
            summaries[k].lines_set = summaries[k].lines_set.union(t.lines_set)

    for datum in data:
        print("\t".join([str(d) for d in datum]))

    getcontext().prec = 2

    print("Repo stats:")
    print(
        "\t".join(
            [
                "kind",
                "files",
                "words",
                "lines",
                "lines_non_blank",
                "distinct_lines",
                "pct_lines_distinct",
                "pct_lines_non_blank_distinct",
            ]
        )
    )
    for k, v in summaries.items():
        pct_lines_distinct: str | Decimal = "n/a"
        pct_lines_non_blank_distinct: str | Decimal = "n/a"
        if v.line_count > 0:
            pct_lines_distinct = Decimal(len(v.lines_set)) / Decimal(v.line_count)
        if v.line_non_blank_count > 0:
            pct_lines_non_blank_distinct = Decimal(len(v.lines_set)) / Decimal(
                v.line_non_blank_count
            )
        print(
            "\t".join(
                [
                    str(s)
                    for s in [
                        v.kind,
                        v.file_count,
                        v.line_count,
                        v.line_non_blank_count,
                        v.word_count,
                        len(v.lines_set),
                        pct_lines_distinct,
                        pct_lines_non_blank_distinct,
                    ]
                ]
            )
        )


def main() -> None:
    repo = Repo.root_repo()
    print(f"first_commit_date: {repo.first_commit_date()}")
    c1 = repo.newest_commit_before_date(S.FIRST_D)
    print(f"newest commit before {S.FIRST_D}: {c1.hexsha} @ {datetime_for_commit(c1)}")

    repo.checkout_repo_at_date(datetime_for_commit(c1).strftime("%Y-%m-%d"))
    repo.checkout_repo_at_date("2021-12-25")

    # print("writing_files:")
    # print_summary()


if __name__ == "__main__":
    main()
