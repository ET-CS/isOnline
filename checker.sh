#!/bin/bash
# Website status checker.
# save all websites to check in file named 'websites.txt'. each in new line.
# leave an empty line in the end.

# Quiet mode. false for test purposes. true for cron.
QUIET=true
# Send mail in case of failure to:
EMAIL=erithq@gmail.com
# list of websites. each website in new line. leave an empty line in the end.
LISTFILE=/scripts/isOnline/websites.txt

# Set THIS_IS_CRON=1 in the beginning of your crontab -e.
# else you will get the log as mail each time
if [ -n "$THIS_IS_CRON" ]; then
    QUIET=true
    #echo "I'm running in cron";
else
    QUIET=false
    #echo "I'm not running in cron";
fi

function test {
  response=$(curl --write-out %{http_code} --silent --output /dev/null $1)
  filename=$( echo $1 | cut -f1 -d"/" )

  if [ "$QUIET" = false ] ; then
    #echo -n "$p (using $filename .cache file) "
    echo -n "$p "
  fi

  #if [ $response -eq 200 ] || [ $response -eq 301 ] ; then
  if [ $response -eq 200 ] ; then
    if [ "$QUIET" = false ] ; then
      echo -n "$response "
      echo -e "\e[32m[ok]\e[0m"
    fi
    if [ -f cache/$filename ]; then
      echo "previously was error."
      rm -f cache/$filename
    fi
  else
    if [ "$QUIET" = false ] ; then
      echo -n "$response "
      echo -e "\e[31m[DOWN]\e[0m"
    fi
    if [ ! -f cache/$filename ]; then
        # using mail command
        #mail -s "$p WEBSITE DOWN" "$EMAIL"
        # using mailx command
        echo "$p WEBSITE DOWN" | mailx -s "$1 WEBSITE DOWN" $EMAIL
        echo > cache/$p
    fi
  fi
}

while read p; do
  test $p
done < $LISTFILE
