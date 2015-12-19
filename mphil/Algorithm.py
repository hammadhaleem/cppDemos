import json


# Define variables 
MAX_TWEETS  = 10**5 * 1.0
time_max = 100.0
percent = MAX_TWEETS / time_max

#loading things 
time_line = json.loads(open("dump.json").read())
N = 2*(10**5) # popularity traget
# Iterative algortihm begins 
keys = []
for i in time_line.keys():
	keys.append(float((i)))
keys = sorted(keys)

next = 0
i = 0


ta = 0 
tb = 0.0 

l_t_b = 0.0
l_t_a = 0.0

n_t_b = 0.0
n_t_a = 0.0

r_a = []
r_b = []



record = ""
while i < 100 : 
	if next >= len(keys):
		print next
		break
	tb = keys[next]
	for obj in time_line[unicode(str(keys[next]))]:
		if (obj['parentId'] == "-1" ) or (obj['reply'] != "-1" ): 
			l_t_b = l_t_b + 1.0
		else:
			n_t_b = n_t_b + 1.0

	'''
	r_n(t_i)
	r_e(t_i)
	phase(i)
	g(ti)
	'''
	'''
	r_bar_(t_i)
	N_bar_(t)
	t_bar_(N)
	'''
	# record = record + str(i) +"," + t_bar_(N) + "\n"
	next = next + 1 
	if ((l_t_b + n_t_b ) > i* percent  ):
		i = i + 1
		r_a.append( [tb, (l_t_a - l_t_b) / (ta - tb)])
		r_b.append( [tb, (n_t_a - n_t_b) / (ta - tb)])

		ta = tb
		l_t_a = l_t_b
		n_t_a = n_t_b

stri = ""
for i in range(0, len(r_a)):
	v1, v2 = r_b[i]
	v3, v4 = r_a[i]
	stri = stri + str(v1 / 60 ) + "," + str(v2) + "," + str(v3 /60)+ ","+ str(v4)+  "," + str(v1/60) + "," + str(v2 + v4)+ "\n"

open("out_percentage.csv","w+").write(stri)