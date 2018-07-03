/*
 * Rscode.h
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */

#ifndef RSCODE_H_
#define RSCODE_H_

#define MM             5
#define NN             31
#define TT             5
#define KK             21

class Rscode {
public:
	Rscode();
	virtual ~Rscode();
	int encode(char *source,int len,char *target);
	bool decode(char *source,int len,char *target);
private:
	static int pp[9];
	int alphaTo[NN+1];
	int indexOf[NN+1];
	int gg[NN-KK+1];
	int recd[NN];
	int data[KK];
	int bb[NN-KK];
	bool isInit;
	void initData();
	void generateGF();
	void generatePolynomial();
	void rsEncode();
	bool rsDecode();
};

#endif /* RSCODE_H_ */
