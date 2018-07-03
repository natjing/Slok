/*
 * Rc4_20.h
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */

#ifndef RC4_20_H_
#define RC4_20_H_

#define RC_CRYPT_KEY		"VQ$df4$#5,{V@$(L"
#define ENCODE_CHAR_NUM		32
class Rc4_20 {
public:
	Rc4_20();
	virtual ~Rc4_20();
	static void init();
	static void Crypt(char*Data, int Len);
private:
	static char key[ENCODE_CHAR_NUM];
	static bool isInit;
};

#endif /* RC4_20_H_ */
