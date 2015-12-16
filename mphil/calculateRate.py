import json
time_line = json.loads(open("dump.json").read())
timer =  time_line.keys()

ta = 0 
tb = 0.0 

l_t_b = 0.0
l_t_a = 0.0

n_t_b = 0.0
n_t_a = 0.0

r_a = []
r_b = []
for item in sorted(timer):
	elements = time_line[item]
	tb = float(item)
	for obj in elements:
		if obj['parentId'] == "-1": 
			l_t_b = l_t_b + 1.0
		else:
			n_t_b = n_t_b + 1.0

	r_a.append( (l_t_a - l_t_b) / (ta - tb))
	r_b.append( (n_t_a - n_t_b) / (ta - tb))

	ta = tb 
	l_t_a = l_t_b
	n_t_a = n_t_b

for i in range(0, len(timer)):
	print r_a[i] , r_b[i] 
