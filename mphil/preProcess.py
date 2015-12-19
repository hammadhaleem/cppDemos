import os, pprint
import time , datetime , collections , json

pp = pprint.PrettyPrinter(depth=6)
data_dir = "data/"
trend = "sharing_bali"

files = next(os.walk(data_dir))[2]
toProcess =[]
factor = 30*60*1.5


for fl in files :
	if trend in str(fl):
		toProcess.append(fl)

data_combined = []
for fi in toProcess:
	lines = open(data_dir + fi ).readlines()
	data_combined = data_combined + lines


# tweetId, id, createdAt, parentId, parentPostTime, replyToUserId, lat, longitude, timezone
data_combined = data_combined[1:] # remvoe header 
lis = []
for i in data_combined :
	i = i.replace("\n","").split(",")
	lis.append(i)
data_combined = lis

 
'''
#Creating a data graph 

data = { 
	"creator" : {
	<information>
	}
}

time_line = {
	time_tweet : [{
		tweetid : <>
		userid : <> 
		parentId: <>
		reply : <>
	}]
}
'''

graph = {}
time_line = {}
mini = 99999909999
for item in data_combined : 
	
	parent = item[3]

	me = item[1]
	time_tweet = item[2]
	tweetId = item[0]
	reply = item[5]

	#Wed Apr 29 13:10:13 CST 2015
	time_tweet = time_tweet.replace("CST","")
	time_tweet = time.mktime(datetime.datetime.strptime(time_tweet, "%a %b %d %H:%M:%S %Y").timetuple())
	time_tweet =  int(time_tweet/(factor))

	if mini > time_tweet : 
		mini = time_tweet
	try :
		if parent is -1:
			raise Exception
		graph[parent].append(me)
	except:
		graph[me] = []

	obj = {
		"tweetid" : tweetId,
		"userid" : me,
		"parentId": parent,
		"reply" : reply
	}

	try:
		time_line[time_tweet].append(obj)
	except Exception as e:
		time_line[time_tweet]= []
		time_line[time_tweet].append(obj)

tmp_data = {}
for tmp in time_line.keys():
	tmp_data[factor*float(tmp - mini +1)] = time_line[tmp]
del time_line

time_line = tmp_data


## constucted timeline for the tweets 
time_line = collections.OrderedDict(sorted(time_line.items()))
open("dump.json","w+").write(json.dumps(time_line))

