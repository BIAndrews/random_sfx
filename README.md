play_random.sh
-------------

A Linux script to randomly play a number of MP3 files from a directory.

Switches
========
1) `-d` Enable debugging.
2) `-c` Set number of files to play.
3) `-p` Set path to MP3 directory.
4) `-h` Help/Usage.

Using [optional] PushOver Notification Example
==============================================
~~~
PUSHOVER_APPTOKEN=jdhfkasuhgfksadfhjk PUSHOVER_USERKEY=97325978f5394f ./play_random.sh -d
~~~

Setting a random Cronjob
========================

Start a job at 10:00am and 1:00pm Monday through Friday, then sleep for up to 3 hours before starting the job.

~~~
0 10,13 * * 1-5 sleep $(( $$ \% 10800 )); /home/pi/sfx/play_random.sh
~~~
