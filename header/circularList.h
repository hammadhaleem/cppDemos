#include<iostream>
#include <string>
#ifndef CICULARLIST_H_
#define CICULARLIST_H_
#define LIS_SIZE  10
#endif /* CICULARLIST_H_ */

class circularList {

	circularList();
	~circularList();
	void insert(int element);
	int pop();
	friend std::ostream & operator<<(std::ostream &os, const circularList& p);
	char* toSt();
private :
	int headIsAhead();
	int *lis_ptr ;
	int head;
	int foot;
};
