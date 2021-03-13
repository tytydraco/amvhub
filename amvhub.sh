#!/usr/bin/env bash
shopt -s globstar
cd "$(dirname "$0")" || exit 1

# ---
export WIDTH="320"
export HEIGHT="-1"
export FPS="30"
export FORMAT="amv"
# ---
export INPUT="../TV Shows"
export OUTPUT="output"
# ---
LOCK=".lock"
LOG="log.txt"

mkdir -p "$OUTPUT"

while [[ -f "$LOCK" ]]
do
    echo "Waiting for lock to release [at: $LOCK]..."
    sleep 1
done

touch "$LOCK"
date >> "$LOG"

_amvhub_convert() {
    local output_file
    local output_dir

    output_file="$(echo "$1" | sed "s|^$INPUT/|$OUTPUT/|")"
    echo "$output_file"
    output_file="${output_file%.*}.$FORMAT"

    [[ -f "$output_file" ]] && return

    output_dir="${output_file%/*}"
    mkdir -p "$output_dir"

    ffmpeg \
        -i "$1" \
        -f "$FORMAT" \
        -vf "scale=$WIDTH:$HEIGHT" \
        -strict -1 \
        -r "$FPS" \
        -ac 1 \
        -ar 22050 \
        -block_size 735 \
        -n \
        -qmin 3 \
        -qmax 3 \
        "$output_file"
}

export -f _amvhub_convert
find "$INPUT" -type f -not -name "*.$FORMAT" -print0 | xargs -0 -I {} bash -c '_amvhub_convert "{}"'

wait

rm -f "$LOCK"

echo ""
echo -e "\033[0;31mFinished amvhub.\033[0m"
echo ""

exit 0
