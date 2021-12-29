#!/usr/bin/env python3
import argparse
from dataclasses import dataclass, field
from decimal import Decimal, getcontext
import os
import subprocess
from typing import Dict, List, Optional, Set

from lib import fountain

# todo: submodule:
# https://github.com/Tagirijus/fountain


class S:
    # default settings
    # override with cli args
    DEBUG = True


def main():
    parser = argparse.ArgumentParser("stats_for_screenplay.py [filepath]")
    parser.add_argument(
        "filepath",
        type=str,
        help="path to fountain file",
    )
    args = parser.parse_args()
    stats_for(args.filepath)


# fyi, this seems to be a more robust version at:
# https://github.com/kortina/sq/blob/d1ac26eca7a69fc0991e910b365c28ae471f23f2/libsq/utils.py#L245
def run_cmd(
    cmd_args: list, cwd: Optional[str | None] = None
) -> subprocess.CompletedProcess:
    cmd = " ".join(cmd_args)
    if S.DEBUG:
        print(f"running:\n{cmd}")

    return subprocess.run(cmd_args, check=True, cwd=cwd, capture_output=True)


def get_cmd_output(cmd_args: list, cwd: Optional[str | None] = None) -> str | None:
    p = run_cmd(cmd_args, cwd)
    stdout = p.stdout
    if not stdout:
        return stdout
    return stdout.decode("utf-8").strip()


def raw(filepath: str) -> str:
    return open(filepath).read()


def stats_for(filepath: str) -> None:
    fountain_string = raw(filepath)
    ps = play_stats(fountain_string)
    render_stats(ps, filepath)


class FT:
    ACTION = "Action"
    BONEYARD = "Boneyard"
    CHARACTER = "Character"
    COMMENT = "Comment"
    DIALOGUE = "Dialogue"
    EMPTY_LINE = "Empty Line"
    PAGE_BREAK = "Page Break"
    PARENTHETICAL = "Parenthetical"
    SCENE_HEADING = "Scene Heading"
    SECTION_HEADING = "Section Heading"
    SYNOPSIS = "Synopsis"
    TRANSITION = "Transition"


@dataclass
class CharacterStats:
    name: str
    line_count: int = 0
    word_count: int = 0
    scenes_set: Set[int] = field(default_factory=set)


@dataclass
class PlayStats:
    word_count: int = 0
    word_count_dialog: int = 0
    line_count: int = 0
    scene_count: int = 0
    characters: Dict[str, CharacterStats] = field(default_factory=dict)


def line_break() -> None:
    print("-" * 80)


def cleanup_char_name_words(words: List[str]) -> List[str]:
    return [w.strip(" .;,\"'-").upper().replace("'S", "") for w in words]


def generate_pdf_and_do_page_count(fountain_filepath: str) -> str:
    # requirements:
    #   npm install -g afterwriting
    #   brew install qpdf

    pdf_filename = f"{os.path.basename(fountain_filepath)}.pdf"
    pdf_filepath = os.path.join("/tmp", pdf_filename)
    # render a pdf in /tmp
    # afterwriting --overwrite --source "$fp_screenplay" --pdf "$fp_pdf" 2>&1 > /dev/null

    run_cmd(
        [
            "afterwriting",
            "--overwrite",
            "--source",
            fountain_filepath,
            "--pdf",
            pdf_filepath,
        ],
    )
    # get the pdf page count:
    return str(get_cmd_output(["qpdf", "--show-npages", pdf_filepath]))


def play_stats(fountain_string: str) -> PlayStats:
    ps = PlayStats()
    f = fountain.Fountain(fountain_string)
    cur_scene = 0
    cur_char: str | None = None
    for el in f.elements:
        if el.element_type == FT.SCENE_HEADING:
            cur_scene += 1
            ps.scene_count += 1

        # set current char, update their stats
        if el.element_type == FT.CHARACTER:
            char_name = el.element_text
            if char_name not in ps.characters:
                ps.characters[char_name] = CharacterStats(char_name)
            ps.characters[char_name].scenes_set.add(cur_scene)
            ps.characters[char_name].line_count += 1

            cur_char = char_name

        # increment word counts
        if el.element_type == FT.DIALOGUE and cur_char and el.element_text:
            wc = len(el.element_text.split())
            ps.characters[cur_char].word_count += wc
            ps.word_count_dialog += wc

        # increment character scene counts based on Action lines
        if cur_scene and el.element_type == FT.ACTION and el.element_text:
            action_words = cleanup_char_name_words(el.element_text.split())
            i = 0
            while i < len(action_words):
                for char in ps.characters.values():
                    char_words = cleanup_char_name_words(char.name.split())
                    n_char_words = len(char_words)
                    # see if the first n_char_words starting at i match the name
                    if action_words[:n_char_words] == char_words:
                        ps.characters[char_name].scenes_set.add(cur_scene)
                i += 1

    return ps


def render_stats(ps: PlayStats, filepath: str) -> None:
    page_count = generate_pdf_and_do_page_count(filepath)
    print("\n")
    line_break()
    print("Screenplay Stats")
    line_break()
    bn = os.path.basename(filepath)
    print(f"File: {bn}")
    print(f"Scenes: {ps.scene_count}")
    print(f"Pages: {page_count}")
    print(f"Characters: {len(ps.characters.keys())}")
    print(f"Words of Dialog: {ps.word_count_dialog}")

    chars = list(ps.characters.values())
    chars.sort(key=lambda x: len(x.name), reverse=True)
    # get the length for ljust char names column
    just_len = len(chars[0].name)

    chars.sort(key=lambda x: x.line_count, reverse=True)

    line_break()
    print("Character Stats")
    line_break()

    print(
        "\t".join(
            [
                "name".ljust(just_len),
                "lines",
                "words",
                "wpct",
                "scenes",
                "spct",
            ]
        )
    )
    for char in chars:
        scene_count = len(char.scenes_set)
        getcontext().prec = 2
        pct_scenes = 100 * Decimal(scene_count) / Decimal(ps.scene_count)
        pct_dialog = 100 * Decimal(char.word_count) / Decimal(ps.word_count_dialog)

        print(
            "\t".join(
                [
                    str(s)
                    for s in [
                        char.name.ljust(just_len),
                        char.line_count,
                        char.word_count,
                        f"{pct_dialog}%",
                        scene_count,
                        f"{pct_scenes}%",
                    ]
                ]
            )
        )


if __name__ == "__main__":
    main()
