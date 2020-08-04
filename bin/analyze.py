#!/usr/bin/env python3
# add noise to csv file
import argparse
import csv
import os
import re


def main():
    parser = argparse.ArgumentParser("python analyze.py")
    parser.add_argument(
        "-i", "--input_csv", type=str, help="input csv file", default=None
    )
    args = parser.parse_args()
    selected = args.input_csv
    if selected is None:
        downloads = os.path.join(os.environ.get("HOME"), "Downloads")
        csvs = list(
            filter(lambda x: re.search(r"^Analytics", x), os.listdir(downloads))
        )
        csvs.sort(
            reverse=True
        )  # csvs are named w dates, so reverse to make first one most recent
        selected = csvs[0]
        if selected is None:
            print("No csv files in ~/Downloads and no `input_csv` arg specified.")
            return
        else:
            i = 0
            for v in csvs:
                s = ""
                if i == 0:
                    s = "* SELECTED"
                    selected = v  # set the selected CSV
                i = i + 1
                print("{} {}".format(v, s))
        selected = os.path.join(downloads, selected)
    with open(selected) as f:
        lines = f.readlines()[6:]
        reader = csv.DictReader(lines)
        print("Users\tAvg. Session\tURL")
        for row in reader:
            if row.get("Source") is None or row.get("Users") is None:
                continue
            url = f'{row["Source"]}{row["Referral Path"]}'
            print(f'{row["Users"]}\t{row["Avg. Session Duration"]}\t{url}')
        print("\nUse `cmd + double click` to open URL.")


if __name__ == "__main__":
    main()
