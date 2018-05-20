#!/bin/bash
#
#  play a random list of MP3's
#
#  v0.1.0 - [optional] env variable PUSHOVER_APPTOKEN and PUSHOVER_USERKEY for remote notify
#  v0.0.1 - initial release
#
######################################################################################################

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ver="0.1.0"                                               # current script version
sfxDir="/home/pi/sfx"                                     # default dir with mp3 files
playCount="3"                                             # default number of files to play
pushoverAPIURL="https://api.pushover.net/1/messages.json" # pushOver API URL

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
      echo "${ver} Usage: $0 [-p ${sfxDir}] [-c ${playCount}] [-d]"
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
  echo "DEBUG: sfxDir=${sfxDir}"
  echo "DEBUG: playCount=${playCount}"
  echo "DEBUG: PUSHOVER_APPTOKEN=${PUSHOVER_APPTOKEN}"
  echo "DEBUG: PUSHOVER_USERKEY=${PUSHOVER_USERKEY}"
fi

# required 3rd party tools, if they don't exist in the path exit 2
reqs=( logger find mpg123 sort head curl )
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

playList=$(find "${sfxDir}" -maxdepth 1 -name "*.mp3" | sort --random-sort | head -n ${playCount}) # random playlist string
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
    # pushover remote notification support
    if [ -n $PUSHOVER_APPTOKEN -a -n $PUSHOVER_USERKEY ];then
      curl -s --form-string "token=${PUSHOVER_APPTOKEN}" --form-string "user=${PUSHOVER_USERKEY}" --form-string "message=$(hostname) played $(basename "${line}")" ${pushoverAPIURL} > /dev/null
      if [ $? -eq 0 ];then
        logger -t $(basename $0) "Sent pushover notification to app_token ${PUSHOVER_APPTOKEN}"
      else
        logger -s -t $(basename $0) "Failed to send pushover notification to app_token:${PUSHOVER_APPTOKEN} user_key:${PUSHOVER_USERKEY}"
      fi
    fi

  else

    logger -s -t $(basename $0) "Error MP3 \"$line\" is not a file..."
    # exit 1

  fi

done

logger -t $(basename $0) "Playlist complete"

test $DEBUG && echo "DEBUG: Script completed exiting 0"

exit
