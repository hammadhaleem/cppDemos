import json , math

#loading things 
time_line = json.loads(open("dump.json").read())
MAX_TWEETS = 0
for k in time_line.keys():
	MAX_TWEETS = MAX_TWEETS + len(time_line[k])


# Define variables 
MAX_TWEETS  = MAX_TWEETS * 1.0
time_max = 100.0
percent = MAX_TWEETS / time_max
recent = 2


def Get_GTi(r_e , r_n):
	su = 0.0
	for i in range(0, len(r_e)):
		su = su + math.log1p(float(r_e[i][1] + r_n[i][1]))
	return su/len(r_e)

def ForJ_one_to_m(R_k_t_i, R_k_t_one , i_counter , m ):
	su = 0.0
	for i in xrange(1, m):
		su = su + (i * (i_counter*1.0)/(time_max*1.0) )*( R_k_t_i - R_k_t_one)
	return su

N = 2*(10**5) # popularity traget
# Iterative algortihm begins 
keys = []
for i in time_line.keys():
	keys.append(float((i)))
keys = sorted(keys)

next = 0
i_counter = 0


ta = 0 
tb = 0.0 

l_t_b = 0.0
l_t_a = 0.0

n_t_b = 0.0
n_t_a = 0.0

r_n = []
r_e = []

mean =[]
mean_recent = []
all_mean =[]

phase = ""
record = ""
while i_counter < 100 : 
	if next >= len(keys):
		print next
		break
	tb = keys[next] 
	for obj in time_line[unicode(str(keys[next]))]:
		if (obj['parentId'] == "-1" ) or (obj['reply'] != "-1" ): 
			l_t_b = l_t_b + 1.0
		else:
			n_t_b = n_t_b + 1.0

	next = next + 1 
	if ((l_t_b + n_t_b ) > i_counter* percent  ):
		i_counter = i_counter + 1


		r_n.append( [tb, (l_t_a - l_t_b) / (ta - tb)])
		r_e.append( [tb, (n_t_a - n_t_b) / (ta - tb)])

		r_f = ((l_t_a - l_t_b) / (ta - tb)) + ((n_t_a - n_t_b) / (ta - tb))

		r_n_mean = 0.0 
		r_e_mean = 0.0 

		r_e_mean_recent = 0.0
		r_n_mean_recent = 0.0

		for i in r_n:
			r_n_mean = r_n_mean + i[1]
		r_n_mean = r_n_mean / float(len(r_n))


		for i in r_e:
			r_e_mean = r_e_mean + i[1]
		r_e_mean = r_e_mean / float(len(r_e))


		sub = r_e[-5:]
		for i in sub:
			r_e_mean_recent = r_e_mean_recent + i[1]
		r_e_mean_recent =r_e_mean_recent / float(len(sub))

		sub = r_n[-5:]
		for i in sub:
			r_n_mean_recent = r_n_mean_recent + i[1]
		r_n_mean_recent =r_n_mean_recent / float(len(sub))


		mean.append([tb, r_n_mean , r_e_mean , r_n_mean + r_e_mean])
		mean_recent.append([tb, r_n_mean_recent , r_e_mean_recent , r_e_mean_recent + r_n_mean_recent])
		
		r_f_mean_recent = r_e_mean_recent + r_n_mean_recent
		r_f_mean =r_n_mean + r_e_mean

		all_mean.append([tb , r_f , r_f_mean_recent, r_f_mean])
		
		# phase calculation 
		if (r_f < r_f_mean) and  (r_f_mean_recent < r_f_mean):
			phase = "rise,fall"


		if (r_f  > r_f_mean) and (r_f_mean_recent  > r_f_mean):
			phase = "fall,rise"

		# getting G(t_i) :  best fit line (global aaverage of values in this case )
		g_t_i = Get_GTi(r_n , r_e)

		# m to number of infection N
		m = int(time_max - i_counter) 


		try:
			R_k_t_one = float (max(0.0 , float(r_n[1][1] + r_e[1][1])))
		except Exception as e :
			R_k_t_one = 0 


		R_k_t_i = float(math.log1p(r_f))
		R_k_t_one =float(math.log1p(R_k_t_one))
		# compute results 
		if phase == "rise,fall" : 
			tmp = R_k_t_i + m * g_t_i  - ForJ_one_to_m(R_k_t_i , R_k_t_one ,  i_counter , m )
			r_dash_k_m = math.exp(tmp)
		else:
			r_dash_k_m = math.exp(R_k_t_i + m * g_t_i)
		
		delta_t_i = (tb -ta)

		try:
			R_n_t_one = float (max(0.0 , float(r_n[1][1])))
		except Exception as e :
			R_n_t_one = 0 

		try:
			R_e_t_one = float (max(0.0 , float(r_e[1][1])))
		except Exception as e :
			R_e_t_one = 0 

		R_e_t_one = float(math.log1p(R_e_t_one))
		R_n_t_one = float(math.log1p(R_n_t_one))

		R_n_t_i = float(math.log1p((l_t_a - l_t_b) / (ta - tb)))
		R_e_t_i = float(math.log1p((n_t_a - n_t_b) / (ta - tb)))

		r_n_bar = ForJ_one_to_m(R_n_t_i , R_n_t_one ,  i_counter , m )
		r_e_bar = ForJ_one_to_m(R_e_t_i , R_e_t_one ,  i_counter , m )

		N_i = l_t_a + n_t_b
		N_i_m = N_i + m * delta_t_i * ( r_n_bar  + r_e_bar )
		if N_i_m >= MAX_TWEETS:
			err = (m*delta_t_i - tb) / tb
			if err < 0:
				err = -1.0*err
			print "Time : " ,i_counter, m  , m*delta_t_i , ta , tb  , err
		#post execution
		ta = tb
		l_t_a = l_t_b
		n_t_a = n_t_b

# output 
stri = ""
for i in range(0, len(r_e)):
	v1, v2 = r_e[i]
	v3, v4 = r_n[i]
	stri = stri + str(v1/60.0) + "," + str(v2) + "," + str(v3/60.0)+ ","+ str(v4)+  "," + str(v1/60.0) + "," + str(v2+v4)+ "\n"

open("out_percentage.csv","w+").write(stri)

#print mean , "\n",mean_recent

stri= "0,0,0,0,0,0\n"
for i in all_mean[1:] :
	stri = stri + str(i[0]) +","+str(i[1])+","+str(i[0])+"," +str(i[2])+","+str(i[0])+","+str(i[3])+"\n"


open("mean_out.csv", "w+").write(stri)


