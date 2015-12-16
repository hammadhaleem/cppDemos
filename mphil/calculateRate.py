import os
import pprint

pp = pprint.PrettyPrinter(depth=6)
data_dir = "data/"
trend = "sharing_bali"

files = next(os.walk(data_dir))[2]
toProcess =[]



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

graph = {
	parent :  < childs >
}
'''

data = {}
graph = {}

for item in data_combined : 
	parent = item[3]
	me = item[1]
	try :
		if parent is -1:
			raise Exception
		graph[parent].append(me)
	except:
		graph[me] = []
keys = graph.keys()

print len(keys)
tmp = []
su = 0 
for i in keys:
	if len(graph[i]) > 0 :
		tmp.append([i , len(graph[i])])
		su =  su + len(graph[i])
print len(tmp) , su
# pp.pprint(graph)