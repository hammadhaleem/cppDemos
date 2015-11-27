#include "../header/circularList.h"
using namespace std;
circularList :: circularList(){
	this->lis_ptr = new int[LIS_SIZE];
	head = 0;
	foot = 0;
};

circularList :: ~circularList(){
	delete[] this->lis_ptr;
};

int circularList::headIsAhead(){
	if (this->head > (LIS_SIZE -1))
		head = 0 ;
	return 0;
};

void circularList:: insert(int n){
	if (head >= LIS_SIZE)
		head = 0;
	else
		head = head + 1;
	if(headIsAhead())
		this->lis_ptr[head] = n;
};

int circularList :: pop(){
	foot = foot + 1;
	if(foot >= LIS_SIZE)
		foot = 0;
	return this->lis_ptr[foot];
}

std::ostream & operator<<(std::ostream &os, const circularList& p)
{
	char *ch = new char[LIS_SIZE];
	for (int i =0 ;i< LIS_SIZE;i++)
		ch[i] = p->lis_ptr[i];
    return os << ch;
}
