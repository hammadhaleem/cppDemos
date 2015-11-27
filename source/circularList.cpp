#include "../header/circularList.h"

circularList :: circularList(){
	this->lis_ptr = new int[LIS_SIZE];
	head = 0;
	foot = 0;
};

circularList :: ~circularList(){
	delete[] this->lis_ptr;
};

int circularList::headIsAhead(){
	while ( this->head < this->foot ){

	}
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
