#!/usr/bin/env python3
import os
import re
import sys

import openai

def generate_filenames(file_contents):
    openai.api_key = os.environ["OPENAI_API_KEY"]
    prompt = f"Based on the following text, generate 5 potential filenames using lowercase letters, numerals, and hyphens:\n\n{file_contents}"
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=prompt,
        max_tokens=100,
        n=1,
        stop=None,
        temperature=0.7,
    )

    suggestions = response.choices[0].text.strip().split('\n')
    return [re.sub(r'[^a-z0-9-.]+', '-', s) for s in suggestions]

def main():
    if len(sys.argv) != 2:
        print("Usage: python rename_file.py <file>")
        sys.exit(1)

    file_path = sys.argv[1]
    with open(file_path, 'rt') as f:
        content = f.read()

    file_basename = os.path.basename(file_path)
    file_extension = os.path.splitext(file_basename)[1]

    filenames = generate_filenames(content)

    print("Options:")
    for i, name in enumerate(filenames, start=1):
        print(f"{i}. {name}{file_extension}")

    choice = int(input("Choose a new filename by entering the corresponding number: "))
    new_filename = filenames[choice - 1] + file_extension

    os.rename(file_path, os.path.join(os.path.dirname(file_path), new_filename))
    print(f"File renamed to: {new_filename}")

if __name__ == "__main__":
    main()