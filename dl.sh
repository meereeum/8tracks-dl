#!/bin/bash

# http://manpages.ubuntu.com/manpages/eoan/en/man1/youtube-dl.1.html
# https://8tracks.com/faq

PLAYLIST="$@"

# extract playlist title
TITLE="$( head -n1 "$@" | grep '^#' | sed -e 's/^#* *//' -e 's/ /_/g' )"
[[ $TITLE ]] || TITLE="." # default: cwd

# --audio-format FORMAT (default: best)
# aac, flac, mp3, m4a, opus, vorbis, wav
# 8tracks compatible: mp3, m4a, aac, mp4

FMT="m4a"

N=$( grep -E '^[^#]+' $PLAYLIST | wc -l )
PLACEHOLDER="##"

MSG="--> $TITLE ($PLACEHOLDER/$N tracks)"

LINES=$( yes '_' | head -n $(( ${#MSG} + 3 )) | tr -d '\n' )
echo $LINES

(( ${#N} <= 2 )) && DIGITS=2 || DIGITS=${#N}

# --audio-quality (lossiness 0-9, default: 5)

# --exec CMD (like in `find`)

# 8tracks: 2 songs per artist or album per playlist

# ignore errors, audio only, continue partial downloads
{
youtube-dl -i -x -c \
           -a "$PLAYLIST" \
           -q --console-title \
           --audio-format $FMT --audio-quality 1 \
           --add-metadata \
           --autonumber-start 0 \
           --restrict-filenames \
           --output "$TITLE/%(autonumber)0${DIGITS}d-%(track)s.%(ext)s" \
           --exec "basename "{}" | sed -e 's/-/: /' -e 's/_/ /g' \
                                       -e 's/^/  /' -e "s/.$FMT$//""

           # --exec 'f="{}"; mv "$f" "${f,,}"'

           # --metadata-from-title "%(artist)s - %(title)s" \
           # --exec 'id3v2 -a "$ARTIST" -t "$SONG"
} &&
{
# lowercase names
WD="$PWD"
cd $TITLE
for f in *.$FMT; do
    mv $f ${f,,}
done
cd "$WD"
} &&
{

echo $LINES

M=$( ls $TITLE/*$FMT | wc -l )
echo -e "$MSG\n" | sed "s/$PLACEHOLDER/$M/"
}

# restore tab title
echo -en "\033]2;Terminal\a"
