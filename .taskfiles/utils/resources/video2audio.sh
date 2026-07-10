#!/bin/bash

DIR="${DIR:-.}"
FORMAT="${FORMAT:-auto}"
QUALITY="${QUALITY:-0}"
OVERWRITE="${OVERWRITE:-false}"
RECURSIVE="${RECURSIVE:-false}"
EXTENSIONS="${EXTENSIONS:-mov mp4 mkv m4v ts avi flv wmv webm}"

for tool in ffmpeg ffprobe; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: $tool is not installed."
        exit 1
    fi
done

if [[ ! -d "$DIR" ]]; then
    echo "Error: directory '$DIR' does not exist."
    exit 1
fi

if [[ "$FORMAT" != "auto" && "$FORMAT" != "mp3" ]]; then
    echo "Error: unknown FORMAT '$FORMAT' (use auto or mp3)."
    exit 1
fi

native_ext () {
    case "$1" in
        mp3) echo "mp3" ;;
        aac|alac) echo "m4a" ;;
        opus) echo "opus" ;;
        vorbis) echo "ogg" ;;
        flac) echo "flac" ;;
        pcm_*) echo "wav" ;;
        ac3) echo "ac3" ;;
        eac3) echo "eac3" ;;
        *) echo "" ;;
    esac
}

extract_copy () {
    local movflags=()
    [[ "$3" == "m4a" ]] && movflags=(-movflags +faststart)
    ffmpeg -hide_banner -loglevel error -y -i "$1" \
        -vn -c:a copy "${movflags[@]}" \
        "$2"
}

encode_mp3 () {
    ffmpeg -hide_banner -loglevel error -y -i "$1" \
        -vn -c:a libmp3lame -q:a "$QUALITY" \
        "$2"
}

convert_file () {
    local input="$1"

    local acodec
    acodec=$(ffprobe -v error -select_streams a:0 \
        -show_entries stream=codec_name -of csv=p=0 "$input")

    if [[ -z "$acodec" ]]; then
        echo "Skipping (no audio stream): $input"
        return
    fi

    local target
    if [[ "$FORMAT" == "auto" ]]; then
        target=$(native_ext "$acodec")
        [[ -z "$target" ]] && target="mp3"
    else
        target="mp3"
    fi

    local output="${input%.*}.${target}"

    if [[ -f "$output" && "$OVERWRITE" != true ]]; then
        echo "Skipping (already exists): $output"
        return
    fi

    if [[ "$(native_ext "$acodec")" == "$target" ]]; then
        echo "Extracting ($acodec, stream copy): $input"
        if extract_copy "$input" "$output" "$target"; then
            echo "OK (lossless): $output"
            return
        fi
        rm -f "$output"
        [[ "$FORMAT" == "auto" ]] || { echo "Error: $input"; return; }
        output="${input%.*}.mp3"
        echo "Copy failed, re-encoding to mp3: $input"
    else
        echo "Encoding (mp3 vbr $QUALITY): $input"
    fi

    if encode_mp3 "$input" "$output"; then
        echo "OK (encoded): $output"
    else
        rm -f "$output"
        echo "Error: $input"
    fi
}

DEPTH_ARGS=()
[[ "$RECURSIVE" != true ]] && DEPTH_ARGS=(-maxdepth 1)

NAME_ARGS=()
for ext in $EXTENSIONS; do
    if [[ ${#NAME_ARGS[@]} -eq 0 ]]; then
        NAME_ARGS=(-iname "*.${ext}")
    else
        NAME_ARGS+=(-o -iname "*.${ext}")
    fi
done

find "$DIR" "${DEPTH_ARGS[@]}" -type f \( "${NAME_ARGS[@]}" \) -print0 \
    | while IFS= read -r -d '' file; do
        convert_file "$file"
    done

echo "Done"
