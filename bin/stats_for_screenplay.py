#!/usr/bin/env python3
import argparse
from collections import defaultdict
from dataclasses import dataclass, field
from decimal import Decimal, getcontext
import os
from nltk import everygrams, FreqDist
import re
import subprocess
from typing import Dict, List, Optional, Set, Tuple

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
    comment_count: int = 0
    dialog_lines: List[str] = field(default_factory=list)
    loc_tods: Dict[str, int] = field(default_factory=dict)
    locs: Dict[str, int] = field(default_factory=dict)


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

    config_path = "~/dotfiles/.afterwriting.config.json"
    run_cmd(
        [
            "afterwriting",
            "--overwrite",
            "--source",
            fountain_filepath,
            "--pdf",
            pdf_filepath,
            "--config",
            config_path,
        ],
    )
    # get the pdf page count:
    return str(get_cmd_output(["qpdf", "--show-npages", pdf_filepath]))


RE_SCENE_TOD = r"(.*)-([^-]+)$"


def location_tod(scene_heading: str) -> str | None:
    m = re.search(RE_SCENE_TOD, scene_heading)
    if not m:
        return None
    tod = m[2].strip("- ").upper()
    if tod in ["LATER", "CONT", "CONTINUOUS", "SAME"]:
        return None
    return tod


def location_with_tod(scene_heading: str, tod: str | None):
    if not tod:
        return scene_heading
    replacement = r"\1" f"- {tod}"
    return re.sub(RE_SCENE_TOD, replacement, scene_heading)


def location_sans_tod(scene_heading: str):
    replacement = r"\1"
    return re.sub(RE_SCENE_TOD, replacement, scene_heading)


def play_stats(fountain_string: str) -> PlayStats:
    ps = PlayStats()
    f = fountain.Fountain(fountain_string)
    cur_scene = 0
    cur_char: str | None = None
    last_loc_tod: str | None = None
    ps.comment_count = f.comment_count

    for el in f.elements:
        if el.element_type == FT.SCENE_HEADING:
            cur_scene += 1
            ps.scene_count += 1

            # get tod from scene heading
            scene_heading = el.element_text
            tod = location_tod(scene_heading)
            # if we got a tod that is not
            #   CONTINUOUS, LATER, SAME
            # use it:
            if tod:
                last_loc_tod = tod
            # swap the actual tod into the scene heading:
            loc_with_tod = location_with_tod(scene_heading, last_loc_tod)
            # add to list of locations
            if loc_with_tod not in ps.loc_tods:
                ps.loc_tods[loc_with_tod] = 0
            ps.loc_tods[loc_with_tod] += 1

            loc_sans_tod = location_sans_tod(scene_heading)
            if loc_sans_tod not in ps.locs:
                ps.locs[loc_sans_tod] = 0
            ps.locs[loc_sans_tod] += 1

        # if el.element_type == FT.COMMENT:
        #     ps.comment_count += 1

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

            # add to the list of all lines of dialog
            ps.dialog_lines.append(el.element_text)

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
    print(f"Locations: {len(ps.locs)}")
    print(f"Loc+TODs: {len(ps.loc_tods)}")
    print(f"Pages: {page_count}")
    print(f"Characters: {len(ps.characters.keys())}")
    print(f"Words of Dialog: {ps.word_count_dialog}")
    print(f"Todos: {ps.comment_count}")

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

    line_break()
    print("n_scn\tLocation+TOD")
    counts = [(k, v) for k, v in ps.loc_tods.items()]
    counts.sort(key=lambda x: x[1], reverse=True)
    for (k, v) in counts:
        print(f"{v}\t{k}")

    # dialog = " ".join(ps.dialog_lines)
    # freq = dialog_ngram_freq(dialog)
    # breakpoint()


# not sure this should remove linebreaks / join lines by different chars...
# TODO: the ngrams need to be extracted from each line of dialog
def clean_dialog(dialog: str) -> List[str]:
    # Given lines of dialog
    # - join them
    # - remove [[notes]]
    # - remove /* boneyards */
    # Return
    #   list of words in order

    # replace multiple spaces and newlines with single spaces
    dialog = re.sub(r"(\s+)", " ", dialog)

    # remove [[notes]]
    dialog = re.sub(r"\[\[.*\]\]", " ", dialog)

    # remove /* boneyards */
    dialog = re.sub(r"\/\*.*\*\/", " ", dialog)

    words = dialog.lower().split()

    # strip trailing punctuation
    words = [w.strip(";_-!.,? ") for w in words]

    # remove empties
    words = [w for w in filter(lambda x: x != "", words)]
    return words


def dialog_ngrams(words: List[str]):
    # return ngrams of len >= 2 <=12
    return [g for g in everygrams(words, min_len=2, max_len=12)]


def ngrams_sort_key(dist_item: Tuple[str, int]) -> int:
    gram, freq = dist_item
    return 100000 * len(gram) + freq


def dialog_ngram_freq(dialog: str):
    words = clean_dialog(dialog)
    grams = dialog_ngrams(words)
    dist_items = [(k, v) for k, v in FreqDist(grams).items()]
    dist_items.sort(key=ngrams_sort_key, reverse=True)

    # remove everything with freq 1
    dist_items = [i for i in filter(lambda x: x[1] > 1, dist_items)]
    return dist_items


if __name__ == "__main__":
    main()
