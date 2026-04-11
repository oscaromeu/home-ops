#!/bin/bash

# ==============================
# Configuration
# ==============================

DIR="${DIR:-.}"                     # Directory to process
QUALITY="${QUALITY:-0}"            # 0 = best VBR quality
OVERWRITE="${OVERWRITE:-false}"    # true to overwrite existing files
RECURSIVE="${RECURSIVE:-false}"    # true to include subdirectories

VIDEO_EXTENSIONS="mov|mp4|mkv|avi|webm|flv|wmv"

# ==============================
# Checks
# ==============================

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed."
    exit 1
fi

if [[ ! -d "$DIR" ]]; then
    echo "Error: directory '$DIR' does not exist."
    exit 1
fi

# ==============================
# Conversion function
# ==============================

convert_file () {
    local input="$1"
    local output="${input%.*}.mp3"

    if [[ -f "$output" && "$OVERWRITE" = false ]]; then
        echo "Skipping (already exists): $output"
        return
    fi

    echo "Converting: $input"

    if ffmpeg -hide_banner -loglevel error -i "$input" \
        -vn -c:a libmp3lame -q:a "$QUALITY" \
        "$output"; then
        echo "OK: $output"
    else
        echo "Error: $input"
    fi
}

# ==============================
# Processing
# ==============================

if [ "$RECURSIVE" = true ]; then
    find "$DIR" -type f -regextype posix-extended -iregex ".*\\.($VIDEO_EXTENSIONS)$" -print0 \
        | while IFS= read -r -d '' file; do
            convert_file "$file"
        done
else
    for ext in mov mp4 mkv avi webm flv wmv; do
        for file in "$DIR"/*."$ext" "$DIR"/*."${ext^^}"; do
            [[ -e "$file" ]] || continue
            convert_file "$file"
        done
    done
fi

echo "Done"
