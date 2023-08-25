#!/bin/bash
# 
# ffmpeg-progress-dialog.sh
# by Timm Thaler
#
# based on the ffmpeg-progress.sh from https://gist.github.com/pruperting/397509
# licensed under the GNU GENERAL PUBLIC LICENSE Version 3
#
# Dependencies / needed software
# ffmpeg (of course)
# dialog (e.g. from apt-get install dialog or homebrew install dialog)
#
# Usage
# ffmpeg-progress-dialog.sh INPUT "ffmpeg arguments" OUTPUT
#

START=$(date +%s)

show_progress() #while ffmpeg is running, parse the stats file and read current frame. Divide by sum of all frames
{
while kill -0 $PID >/dev/null 2>&1
do
    VSTATS=$(awk '{gsub(/frame=/, "")}/./{line=$1-1} END{print line}' ~/ffmpeg_stats.txt | sed "s/frame=\([^0-9]\)//g" | sed "s/\(.*\) fps.*/\1/p")
    VSTATS=$((VSTATS+0))
    if [ $VSTATS -gt $FR_CNT ]; then
        if [ $VSTATS -gt 99 ]; then
            VSTATS=$((VSTATS+1))
        fi
        FR_CNT=$VSTATS
        echo $((VSTATS*100/FRAMES))
    fi
done | dialog --title "Converting ..." --gauge "\nInput-Datei:\n$NAME\n\nOutput-Datei:\n$OUTN" 15 70 0
}

FILE="$1"
ARGS="$2"
OUTP="$3"
NAME=${1##*/}
OUTN=${3##*/}

FR_CNT=0

# Create stats file, so we get no errors when not written by ffmpeg
echo "" >> ~/ffmpeg_stats.txt

# get number of video frames of the whole file
FRAMES=$(ffprobe -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 -v quiet -i "$FILE")

# start video conversion in background and write stats to file in home directory
ffmpeg -i "$FILE" -v error -vstats -vstats_file ~/ffmpeg_stats.txt -hide_banner $ARGS -y "$OUTP" 2>/dev/null & PID=$! &&

# Show progress bar
show_progress

#rm -f ~/ffmpeg_stats.txt

# make some noise when finished
echo -e "\a"

ELAPSED=$(( $(date +%s) - START ))
echo $ELAPSED
#dialog --title "Done" --msgbox "\nInput:\n$NAME\n\nOutput:\n$OUTN\n\n\nConverting finished.\n\nElapsed time: $((ELAPSED/3600)) HRS  $((ELAPSED%3600/60)) MIN  $((ELAPSED%60)) SEC" 15 70
