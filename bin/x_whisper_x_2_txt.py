#!/usr/bin/env python3
import os
import subprocess
import sys

"""
# Setup

    mkdir ~/src
    cd ~/src
    gh repo clone ggerganov/whisper.cpp
    cd whisper.cpp
    bash ./models/download-ggml-model.sh base.en
    make

# Reference

https://github.com/ggerganov/whisper.cpp

"""


def convert_to_wav(input_file):
    output_file = os.path.splitext(input_file)[0] + ".WHISPER.wav"
    output_file = os.path.abspath(output_file)
    if os.path.exists(output_file):
        print("WARNING: WAV file already exists, skipping conversion")
        return output_file
    command = [
        "ffmpeg",
        "-i",
        input_file,
        "-ar",
        "16000",
        "-ac",
        "1",
        "-c:a",
        "pcm_s16le",
        output_file,
    ]
    subprocess.run(command)

    return output_file


def transcribe_wav_file(wav_file):
    whisper_d = os.path.expanduser("~/src/whisper.cpp")
    whisper_x = os.path.join(whisper_d, "main")
    whisper_m = os.path.join(whisper_d, "models", "ggml-base.en.bin")

    command = [
        whisper_x,
        "--output-txt",
        "--output-vtt",
        "--output-srt",
        "-m",
        whisper_m,
        "-f",
        wav_file,
    ]
    print("----------")
    print("RUNNING:")
    print(" ".join(command))
    print("----------")
    subprocess.run(command, cwd=whisper_d)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    if not os.path.isfile(input_file):
        print(f"File {input_file} does not exist!")
        sys.exit(1)

    # Convert the input file to WAV format
    wav_file = convert_to_wav(input_file)

    # Transcribe the WAV file using whisper.cpp
    transcribe_wav_file(wav_file)
