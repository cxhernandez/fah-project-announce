#!/bin/bash
################################################################################
# THIS SCRIPT GENERATES AN RSS FEED WITH THE LATEST BETA PROJECTS ADDED TO FAH
# THIS SCRIPT IS INTENDED TO NOTIFY INTERNAL USERS OF NEW PROJECTS VIA FAH SLACK
################################################################################

URI=http://assign.stanford.edu/api/project/summary #FAH JSON API
TMP=/home/server/announcements/psummary.json.tmp #PATH JSON STRING DOWNLOAD (TEMPORARY)
JSON=/home/server/announcements/psummary.json #PATH TO LOCAL VERSION OF JSON STRING
FEED=/home/server/announcements/fah-beta.xml #PATH TO UP-TO-DATE VERSION OF RSS FEED

#JSONSIZE=$(wc -c "$JSON" | cut -f 1 -d ' ') #GET SIZE OF LOCAL JSON STRING

wget -q -N -T 10 -t 1 --output-document=$TMP $URI #DOWNLOAD JSON STRING FROM AS

TMPSIZE=$(wc -c "$TMP" | cut -f 1 -d ' ') #GET SIZE OF DOWNLOADED JSON STRING

DIFF=`cmp $JSON $TMP` #CHECK FOR DIFFERENCES IN FILE

#IF DOWNLOAD IS NOT EMPTY AND THERE ARE DIFFERENCES THEN UPDATE RSS FEED
if [ "$TMPSIZE" -gt 0  ] && [ -n "$DIFF" ]; then 
	mv $FEED ${FEED}.old #DEPRECATE PREVIOUS VERSION OF RSS FEED
	python /home/server/announcements/psummary-rss.py | head -n -3> $FEED #GENERATE NEW RSS FEED ITEMS
	grep -A6 -m 4 "<item>" ${FEED}.old >> $FEED #INCLUDE 4 OF THE PREVIOUS RSS ITEMS (THIS IS NECESSARY FOR IFTTT TO RECOGNIZE CHANGES)
	echo -e "\t</channel>" >> $FEED #END CHANNEL
	echo "</rss>" >> $FEED #END RSS FEED

	scp $FEED cxh@corn.stanford.edu:~/WWW/ #UPLOAD TO CORN
	mv $TMP $JSON #UPDATE LOCAL VERSION OF JSON STRING
else 
	rm $TMP #DELETE USELESS VERSION OF JSON STRING
fi
