#!/usr/bin/env bash
shopt -s globstar
cd "$(dirname "$0")"

# ---
WIDTH="320"
HEIGHT="-1"
FPS="30"
# ---
INPUT="input"
OUTPUT="output"
LOCK=".lock"
LOG="log.txt"

while [[ -f "$LOCK" ]]
do
    echo "Waiting for lock to release [at: $LOCK]..."
    sleep 1
done

touch "$LOCK"
echo "$(date)" >> "$LOG"

mkdir -p "$OUTPUT"

convert() {
    local basename
    basename="$(basename "$1")"
    name="$(echo "$basename" | cut -f 1 -d '.')"

    ffmpeg \
        -i "$1" \
        -f amv \
        -vf "scale=$WIDTH:$HEIGHT" \
        -strict -1 \
        -r "$FPS" \
        -ac 1 \
        -ar 22050 \
        -block_size 735 \
        -n \
	-qmin 3 \
	-qmax 3 \
        "$OUTPUT/$name.amv"
}

for amv in "$INPUT"/**/*
do
    [[ "$amv" == "$INPUT/**/*" ]] && continue
    [[ "$amv" == ".gitkeep" ]] && continue
    convert "$amv"
done

rm -f "$LOCK"

echo ""
echo -e "\033[0;31mFinished amvhub.\033[0m"
echo ""

exit 0
