import json

time_line = json.loads(open("out/dump.json").read())
timer =[]

for i in time_line.keys():
	timer.append(float(i))

ta = 0 
tb = 0.0 

l_t_b = 0.0
l_t_a = 0.0

n_t_b = 0.0
n_t_a = 0.0

r_a = []
r_b = []

for item in sorted(timer):
	elements = time_line[str(item)]
	tb = int(item) 
	for obj in elements:
		if (obj['parentId'] == "-1" ) or (obj['reply'] != "-1" ): 
			l_t_b = l_t_b + 1.0
		else:
			n_t_b = n_t_b + 1.0

	r_a.append( [tb, (l_t_a - l_t_b) / (ta - tb)])
	r_b.append( [tb, (n_t_a - n_t_b) / (ta - tb)])

	ta = tb
	l_t_a = l_t_b
	n_t_a = n_t_b

stri = ""
for i in range(0, len(timer)):
	v1, v2 = r_b[i]
	v3, v4 = r_a[i]
	stri = stri + str(v1 / 60 ) + "," + str(v2) + "," + str(v3 /60)+ ","+ str(v4)+  "," + str(v1/60) + "," + str(v2 + v4)+ "\n"

open("out/out_time.csv","w+").write(stri)
