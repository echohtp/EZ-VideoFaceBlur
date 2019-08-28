#!/bin/bash

echo -e "Starting process\n\n\n"
echo "{EXPLODE}"
mkdir -p explode;
mkdir -p blur;
FRAMERATE=$(ffmpeg -i $1 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
ffmpeg  -i $1 -r 1  explode/%04d.jpeg -hide_banner;

echo -echo "\n\n\BLUR STUFF\n\n"

python3 blur.py


echo -e "\nRECOMBINATE\n"

ffmpeg -i ./blur/%04d.jpeg  -vcodec mpeg4  -r 25 ./out.avi;

echo "Cleaning up"
rm -rf explode/ blur/
echo  -e "Done\n"