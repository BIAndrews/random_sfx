#!/bin/bash
#
#  play a random list of MP3's to annoy the stupid ass dog.
#
#  v0.0.1 - stop fucking barking at nothing rc1
#
#######################################################################

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

sfxDir="/home/pi/sfx" # default dir with mp3 files
playCount="3"         # default number of files to play

while getopts ":dp:c:" opt; do
  case ${opt} in
    d)
      DEBUG=true
      ;;
    p)
      sfxDir=$OPTARG
      ;;
    c)
      playCount=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-p ${sfxDir}] [-c ${playCount}] [-d]"
      echo
      echo "    -p   Path to dir with MP3s."
      echo "    -c   number of randomly picked files to play."
      echo "    -d   Enable debugging output."
      exit 1
      ;;
  esac
done

#########################################################################################
#
# preflight check
#

if [ $DEBUG ];then
  echo "DEBUG: sfxDir=$sfxDir"
  echo "DEBUG: playCount=$playCount"
fi

reqs=( logger find mpg123 sort head )
for i in "${reqs[@]}"; do
  command -v $i >/dev/null 2>&1 || { echo >&2 "I require ${i} but it's not installed.  Aborting."; exit 2; }
done

if [ ! -d "$sfxDir" ];then
  logger -s -t $(basename $0) "Error: \"$sfxDir\" is not a directory"
  exit 3
fi

#########################################################################################
#
# build a playlist
#

playList=$(find "${sfxDir}" -name "*.mp3" | sort --random-sort | head -n ${playCount}) # random playlist string
if [ -z "$playList" ];then
  logger -s -t $(basename $0) "Error no MP3 files found"
  exit 4
fi

if [ $DEBUG ];then
  echo -e "DEBUG: Playlist:\n${playList}"
fi

#########################################################################################
#
# verify and play the list
#

logger -t $(basename $0) "Playing $playCount files..."

echo "$playList" | while IFS= read -r line ; do

  #########################################################
  #
  # loop through each line in playlist, verify, play mp3
  #
  if [ -f "$line" ];then
    test $DEBUG && echo "DEBUG: Playing MP3 \"$line\"..."
    logger -t $(basename $0) "Playing MP3 \"$line\""
    mpg123 -q "$line"
  else
    logger -s -t $(basename $0) "Error MP3 \"$line\" is not a file..."
    # exit 1
  fi

done

logger -t $(basename $0) "Playlist complete"

test $DEBUG && echo "DEBUG: Script completed exiting 0"

exit
