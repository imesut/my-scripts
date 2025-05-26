#!/bin/bash

# glob operator * might produce undesired outcome, if no stl file is in the folder. Here is fix for zsh and bash
shopt -s nullglob
setopt +o nomatch
#  brew install openscad
#  brew install imagemagick
#  brew install qrencode

# Theme - bg - body
# BeforeDawn - Gray - White
# Cornfield - Light Yellow - Yellow
# NOK - Metallic - Purple - White
# NOK - Sunset - Red - Light Red
# Starnight - Black - Light Yellow
# BeforeDawn - Gray - White
# Nature - White - Green
# DeepOcean - Gray - White
# Solarized - Light Yellow - Dark Yellow
# Tomorrow - White - Blue
# TomorrowNight
# Monotone - Light Yellow - Yellow

FOLDER="${1:-.}"
THEME="${2:-DeepOcean}"

# Settings
OPENSCADPATH="/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"
# THEME="DeepOcean"
FRAME_COUNT=45
# FRAME_COUNT=2
WIDTH=350
HEIGHT=350

scad_template="turntable_template.scad"

echo "FOLDER:" "$FOLDER"

# Loop through all .stl files in the current directory
for folderContent in "$FOLDER"/*.stl; do
    filenameWithExtesion=$(basename "$folderContent")
    filename="${filenameWithExtesion%.stl}"
    filePath="$FOLDER"/"$filenameWithExtesion"
    echo "filename" $filename
    echo "filepath" $filePath
    echo "filenameWithExtesion" $filenameWithExtesion
    mkdir -p frames_"$filename"

    echo "Generating frames for $filename..."

    cat > "$scad_template" <<EOF
rotate([0,0,\$t*360])
import("$filePath", center=true);
EOF

    # Render frames using OpenSCAD
    for i in $(seq 0 $(($FRAME_COUNT-1))); do
        t=$(echo "$i / $FRAME_COUNT" | bc -l)
        frame_num=$(printf "%03d" "$i")
        output="frames_${filename}/frame_${frame_num}.png"

        "$OPENSCADPATH" -o "$output" -D '$t='$t "$scad_template" \
            --imgsize=$WIDTH,$HEIGHT \
            --colorscheme=$THEME \
            --projection=perspective
    done

    # Create GIF with ImageMagick
    echo "Creating GIF for $filename..."

    echo "$filename.gif"

    magick frames_${filename}/frame_*.png -coalesce \
        null: overlay.png -gravity center -layers composite \
        -fill white -pointsize 12 -gravity southwest -annotate +10+17 $filename \
        -layers optimize "$FOLDER"/"$filename.gif"

    rm -r frames_"$filename"

    echo "✅ Done: $filename.gif created"
done

rm "$scad_template"

shopt -u nullglob