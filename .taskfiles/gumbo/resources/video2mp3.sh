#!/bin/bash

# ==============================
# Configuración
# ==============================

QUALITY=0            # 0 = máxima calidad VBR
OVERWRITE=false      # true para sobrescribir
RECURSIVE=false      # true para incluir subcarpetas

# ==============================
# Comprobaciones
# ==============================

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg no está instalado."
    exit 1
fi

# ==============================
# Función de conversión
# ==============================

convert_file () {
    input="$1"
    output="${input%.*}.mp3"

    if [[ -f "$output" && "$OVERWRITE" = false ]]; then
        echo "Saltando (ya existe): $output"
        return
    fi

    echo "Convirtiendo: $input"

    ffmpeg -hide_banner -loglevel error -i "$input" \
        -vn -c:a libmp3lame -q:a $QUALITY \
        "$output"

    if [[ $? -eq 0 ]]; then
        echo "✔ OK: $output"
    else
        echo "✖ Error: $input"
    fi
}

# ==============================
# Procesamiento
# ==============================

if [ "$RECURSIVE" = true ]; then
    find . -type f -iname "*.mov" | while read -r file; do
        convert_file "$file"
    done
else
    for file in *.mov; do
        [[ -e "$file" ]] || continue
        convert_file "$file"
    done
fi

echo "✅ Conversión terminada"
