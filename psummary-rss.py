# This script identifies new FAH projects using the AS JSON STRING API
# and then generates an RSS feed to notify FAH Slack users.
import json
import pytz
from datetime import datetime
from feedgen.feed import FeedGenerator

fg = FeedGenerator()
fg.title('New FAH Beta Projects')
fg.link( href='http://web.stanford.edu/~cxh/fah-beta.xml', rel='self' )
fg.author( {'name':'cxh','email':'cxh@stanford.edu'} )
fg.description('A list of the most recent beta Projects on Folding@home')
fg.id('http://web.stanford.edu/~cxh/fah-beta.xml')
fg.language('en')

old_projects = json.load(open('/home/server/announcements/psummary.json','rb'))
new_projects = projects = json.load(open('/home/server/announcements/psummary.json.tmp','rb'))
old = [project['id'] for project in old_projects] 
for project in new_projects:
	if project['beta'] and project['id'] not in old:
		fe = fg.add_entry()
		fe.id('proj' + str(project['id']))
		fe.title('Project ' + str(project['id']))
		fe.link({'href': 'http://assign.stanford.edu/api/project/summary'})
		fe.published(datetime.now(pytz.utc))
		fe.description(project['contact'] + ' has started project ' + str(project['id']) + ". Tune into channel #" + str(project['id'])[:-2] + "00 for more information.")

#fg.rss_file('/home/server/announcements/fah-beta.xml')
print fg.rss_str(pretty=True)
