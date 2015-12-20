import json , math


def getMean(lis):
	su = 0.0
	for i in lis :
		su = su + i[1]
	return  su / (1.0 * float(len(lis)))

def Get_GTi(r_e , r_n):
	su = 0.0
	for i in range(0, len(r_e)):
		su = su + math.log(float(r_e[i][1] + r_n[i][1]))
	return su/len(r_e)

def ForJ_one_to_m(R_k_t_i, R_k_t_one , i_counter , m ):
	su = 0.0
	for i in xrange(1, m):
		su = su + (i * float(i_counter)/(100.0))*( R_k_t_i - R_k_t_one)

	return su


#loading things 

time_line = json.loads(open("out/dump.json").read())
# load all tweets processed 

MAX_TWEETS = 0.0

for k in time_line.keys():
	MAX_TWEETS = MAX_TWEETS + len(time_line[k])*1.0
print "Max tweets : " , MAX_TWEETS

# Max number of tweets

# Define variables 



# Iterative algortihm begins 
keys = []
TIME_END =0.0
for i in sorted(time_line.keys()):
	keys.append(float((i)))
	
keys = sorted(keys)

### 
popularity_traget= 150900
time_to_target = 0.0
su = 0
for tmp in keys: 
	su = su + len(time_line[str(tmp)])
	if su > popularity_traget:
		time_to_target = tmp
		break 
## Define 

time_max = 100.0
percent = popularity_traget / time_max
recent = 5

## Algorithm begins 

mini = 999999
maxi = -999999
next = 0
i_counter = 0

g_t_i = 0.0
ta = 0.0
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

phase = "rise,fall"
accu =""
g_list = []
g_list_1 = []


while i_counter <= 100 : 

	## Break away condition 
	if next >= len(keys):
		print "break : " , next
		break

	tb = keys[next] 
	for obj in time_line[unicode(str(keys[next]))]:
		if (obj['parentId'] == "-1" ) or (obj['reply'] != "-1" ): 
			l_t_b = l_t_b + 1.0
		else:
			n_t_b = n_t_b + 1.0

	if ((l_t_b + n_t_b ) >= i_counter* percent  ):  # when the counter moves ahead by x percent 
		
		rate_n = (l_t_a - l_t_b) / (ta - tb)
		rate_e = (n_t_a - n_t_b) / (ta - tb)
		r_n.append( [tb,  rate_n])
		r_e.append( [tb,  rate_e])

		r_f = (rate_e + rate_n)
		r_n_mean = getMean(r_n) 
		r_e_mean = getMean(r_e)

		r_e_mean_recent =  getMean(r_e[-recent:])
		r_n_mean_recent =  getMean(r_n[-recent:])
		r_f_mean_recent = r_e_mean_recent + r_n_mean_recent
		r_f_mean =r_n_mean + r_e_mean

		mean.append([tb, r_n_mean , r_e_mean , r_n_mean + r_e_mean]) # for storage and visualizaiton
		mean_recent.append([tb, r_n_mean_recent , r_e_mean_recent , r_e_mean_recent + r_n_mean_recent]) # for storage and visualizaiton
		all_mean.append([tb , r_f , r_f_mean_recent, r_f_mean]) # for storage and visualizaiton
		
		g_t_i =0.0 # phase calculation 
		
		if (r_f < r_f_mean) and  (r_f_mean_recent < r_f_mean):
			if phase != "rise,fall":
				phase = "rise,fall"

		if (r_f >= r_f_mean) and  (r_f_mean_recent >= r_f_mean):
			if phase != "fall,rise":
				phase = "fall,rise"
		
		if r_f > maxi:
			maxi = r_f
		if r_f < mini:
			mini = r_f

		g_list_1.append(r_f)
		g_list.append( [r_f , tb ])
		t=0
		if phase == "rise,fall":
			index = g_list_1.index(maxi)
		else:
			index = g_list_1.index(mini)

		for i in g_list[index:]:
			g_t_i = g_t_i + math.log(i[0]) / i[1] 
			t=t+ i[1]

		# g_t_i =g_t_i / len(g_list)

		if phase is "fall,rise":
			if g_t_i < 0 :
				g_t_i = g_t_i *-1
		else:
			if g_t_i > 0:
				g_t_i = g_t_i *-1

		# print i_counter , phase , g_t_i ,r_f
		# m to number of infection N

		m = int(time_max - i_counter) 

		try:
			R_k_t_one = float (max(0.0 , float(r_n[1][1] + r_e[1][1])))
		except Exception as e :
			R_k_t_one = 1

		R_k_t_i   =float(math.log(r_f))
		R_k_t_one =float(math.log(R_k_t_one))


		# compute results 
		# if phase == "rise,fall" : 
		# 	r_dash_k_m = math.exp(R_k_t_i + ( m * g_t_i ) - ForJ_one_to_m(R_k_t_i , R_k_t_one ,  i_counter , m))
		# else:
		# 	r_dash_k_m = math.exp(R_k_t_i + m * g_t_i)
		
		delta_t_i = (tb -ta)

		try:
			R_n_t_one = float(r_n[1][1])
		except Exception as e :
			R_n_t_one = 1

		try:
			R_e_t_one = float(r_e[1][1])
		except Exception as e :
			R_e_t_one = 1

		R_e_t_one = float(math.log(R_e_t_one))
		R_n_t_one = float(math.log(R_n_t_one))

		# print R_e_t_one,R_n_t_one
		
		R_e_t_i = float(math.log(rate_e))
		R_n_t_i = float(math.log(rate_n))

		tmp_m = m 
		r_n_bar = 0.0
		r_e_bar = 0.0
		for m in xrange(1, tmp_m):
			try:
				if phase is "rise,fall" : 
					r_n_bar = r_n_bar + math.exp(math.log(rate_n) + m * g_t_i - ForJ_one_to_m(R_n_t_i , R_n_t_one ,  i_counter , m ))
					r_e_bar = r_e_bar + math.exp(math.log(rate_e) + m * g_t_i - ForJ_one_to_m(R_e_t_i , R_e_t_one ,  i_counter , m ))
				else:
					r_n_bar = r_n_bar + math.exp(math.log(rate_n) + m * g_t_i )
					r_e_bar = r_e_bar + math.exp(math.log(rate_e) + m * g_t_i )

			except Exception as e:
				print "ERR",e


			N_i = l_t_a + n_t_b
			N_i_m = N_i + m * delta_t_i * (r_n_bar  + r_e_bar) 
			if N_i_m >= popularity_traget:
				tmp_m = m+1
				# print m
				break
		
		# print m ,tmp_m, g_t_i ,delta_t_i, rate_n, rate_n * math.exp( - m * g_t_i) 
		m =tmp_m
		N_i = l_t_a + n_t_b
		N_i_m = N_i + m * delta_t_i * (r_n_bar  + r_e_bar)

		if N_i_m >= popularity_traget*0.9:
			T_calc = tb + m*delta_t_i

			err = (T_calc - time_to_target) / time_to_target
			if err < 0:
				err = -1.0*err

			err_n = (N_i_m - N_i )/ MAX_TWEETS

			accu = accu + str(i_counter) + "," +str(err) + "\n"
			print "i : " , i_counter , " m : ", m , " err : " , err , g_t_i  , r_n_bar + r_e_bar

		#post execution
		ta = tb
		l_t_a = l_t_b
		n_t_a = n_t_b

		#Confirm that the time % distribution is alright.
		# print i_counter , n_t_b + l_t_b , time_to_target , (n_t_b + l_t_b) / MAX_TWEETS
		i_counter = i_counter + 1

	next = next + 1 
print "Time of END" , tb

stri = ""
for i in range(0, len(r_e)):
	v1, v2 = r_e[i]
	v3, v4 = r_n[i]
	stri = stri + str(v1/60.0) + "," + str(v2) + "," + str(v3/60.0)+ ","+ str(v4)+  "," + str(v1/60.0) + "," + str(v2+v4)+ "\n"


#print mean , "\n",mean_recent

stri1= "0,0,0,0,0,0\n"
for i in all_mean[1:] :
	stri1 = stri1 + str(i[0]) +","+str(i[1])+","+str(i[0])+"," +str(i[2])+","+str(i[0])+","+str(i[3])+"\n"


open("out/out_percentage.csv","w+").write(stri)
open("out/mean_out.csv", "w+").write(stri1)
open("out/accu.csv","w+").write(accu)
