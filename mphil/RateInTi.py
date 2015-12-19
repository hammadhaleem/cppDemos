import json

time_line = json.loads(open("dump.json").read())
item_list =[]
for key in time_line.keys():
	for i in time_line[key]:
		item_list.append([key,i])

MAX_ITEM = 10**4
max_time = 100
counter = MAX_ITEM / max_time


ta = 0 
tb = 0.0 

l_t_b = 0.0
l_t_a = 0.0

n_t_b = 0.0
n_t_a = 0.0

r_a = []
r_b = []

i = 1
next = 0
while i <= max_time : 

	tb = i
	obj = item_list[next]
	tb , obj = int(float(obj[0])) , obj[1]
	if (obj['parentId'] == "-1" ) or (obj['reply'] != "-1" ): 
		l_t_b = l_t_b + 1.0
	else:
		n_t_b = n_t_b + 1.0

	try:
		r_a.append( [tb, (l_t_a - l_t_b) / (ta - tb)])
		r_b.append( [tb, (n_t_a - n_t_b) / (ta - tb)])
	except Exception as e :
		print e
		print tb ,ta


	
	if next % counter is 0:
		i = i + 1
		ta = tb
		l_t_a = l_t_b
		n_t_a = n_t_b
	next = next + 1

stri = ""

for i in range(0, len(r_b)):
	v1, v2 =r_b[i]
	v3,v4  =r_a[i]
	stri = stri + str(v1) + "," + str(v2) + "," + str(v3)+ ","+ str(v4)+  "," + str(v1) + "," + str(v2 + v4)+ "\n"

open("out_percentage.csv","w+").write(stri)
