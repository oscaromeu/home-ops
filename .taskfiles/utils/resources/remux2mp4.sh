#!/bin/bash

DIR="${DIR:-.}"
MODE="${MODE:-auto}"
QUALITY="${QUALITY:-18}"
OVERWRITE="${OVERWRITE:-false}"
RECURSIVE="${RECURSIVE:-false}"
EXTENSIONS="${EXTENSIONS:-mov mkv m4v ts avi flv wmv webm}"

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

if [[ "$MODE" != "auto" && "$MODE" != "copy" && "$MODE" != "encode" ]]; then
    echo "Error: unknown MODE '$MODE' (use auto, copy or encode)."
    exit 1
fi

remux () {
    ffmpeg -hide_banner -loglevel error -y -i "$1" \
        -c copy "${TAG_ARGS[@]}" -movflags +faststart \
        "$2"
}

remux_video_only () {
    ffmpeg -hide_banner -loglevel error -y -i "$1" \
        -c:v copy "${TAG_ARGS[@]}" -c:a aac -b:a 256k -movflags +faststart \
        "$2"
}

encode () {
    ffmpeg -hide_banner -loglevel error -y -i "$1" \
        -c:v libx264 -crf "$QUALITY" -preset slow \
        -c:a aac -b:a 256k -movflags +faststart \
        "$2"
}

convert_file () {
    local input="$1"
    local output="${input%.*}.mp4"

    if [[ -f "$output" && "$OVERWRITE" != true ]]; then
        echo "Skipping (already exists): $output"
        return
    fi

    local vcodec
    vcodec=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=codec_name -of csv=p=0 "$input")
    TAG_ARGS=()
    [[ "$vcodec" == "hevc" ]] && TAG_ARGS=(-tag:v hvc1)

    case "$MODE" in
        copy)
            echo "Remuxing: $input"
            if remux "$input" "$output"; then
                echo "OK (lossless remux): $output"
            else
                rm -f "$output"
                echo "Error: $input (codecs not mp4-compatible, try MODE=auto)"
            fi
            ;;
        encode)
            echo "Encoding (crf $QUALITY): $input"
            if encode "$input" "$output"; then
                echo "OK (encoded): $output"
            else
                rm -f "$output"
                echo "Error: $input"
            fi
            ;;
        auto)
            if remux "$input" "$output" 2> /dev/null; then
                echo "OK (lossless remux): $output"
                return
            fi
            rm -f "$output"
            if remux_video_only "$input" "$output" 2> /dev/null; then
                echo "OK (video copied, audio -> aac): $output"
                return
            fi
            rm -f "$output"
            echo "Re-encoding (crf $QUALITY): $input"
            if encode "$input" "$output"; then
                echo "OK (encoded): $output"
            else
                rm -f "$output"
                echo "Error: $input"
            fi
            ;;
    esac
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
