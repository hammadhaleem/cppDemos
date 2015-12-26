data = open("matlab_data/cleardatatotal.csv").readlines()
objs = []
time_line = {}
err_counter = 0 

for line in data : 
	i  = line.split(",")
	obj = {}
	obj['time'] = float(i[0])
	obj['user_id'] = float(i[1])
	obj['story_id'] =float(i[2])
	obj['cascade_id'] = float(i[3])
	obj['parent_id'] = float(i[4])
	obj['parent_voting_time'] = float(i[5])
	obj['generation'] = float(i[6])
	objs.append(obj)
	try:
		time_line[ float(obj['time']) / (60*60) ].append(obj)
	except:
		err_counter = err_counter + 1
		time_line[ float(obj['time']) / (60*60)] = [obj]


