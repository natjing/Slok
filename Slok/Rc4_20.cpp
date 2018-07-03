/*
 * Rc4_20.cpp
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */

#include <stdio.h>
#include <string.h>
#include "Rc4_20.h"

char Rc4_20::key[ENCODE_CHAR_NUM];
bool Rc4_20::isInit=false;

Rc4_20::Rc4_20() {
	// TODO Auto-generated constructor stub
}

Rc4_20::~Rc4_20() {
	// TODO Auto-generated destructor stub
}
void Rc4_20::init()
{
	if(isInit)
		return ;
	memset(Rc4_20::key,0,sizeof(Rc4_20::key));
	int i = 0, j = 0;
	char k[ENCODE_CHAR_NUM] = { 0 };
	char ckey[16];
	memset(ckey,0,sizeof(ckey));
	memcpy(ckey,RC_CRYPT_KEY,sizeof(ckey));
	unsigned char tmp = 0;
	for (i = 0; i < ENCODE_CHAR_NUM; i++) {
		Rc4_20::key[i] = i;
		k[i] = ckey[i % 16];
	}
	for (i = 0; i < ENCODE_CHAR_NUM; i++) {
		j = (j + Rc4_20::key[i] + k[i]) % ENCODE_CHAR_NUM;
		tmp = Rc4_20::key[i];
		Rc4_20::key[i] = Rc4_20::key[j]; //交换s[i]和s[j]
		Rc4_20::key[j] = tmp;
	}
	isInit=true;
}
/*加解密*/
void Rc4_20::Crypt(char*Data, int Len)
{
	init();
	char sk[ENCODE_CHAR_NUM];
	memcpy(sk,Rc4_20::key,ENCODE_CHAR_NUM);
    int i = 0, j = 0, t = 0;
    unsigned long k = 0;
    unsigned char tmp;
    for (k = 0; k<Len; k++)
    {
        i = (i + 1) % ENCODE_CHAR_NUM;
        j = (j + sk[i]) % ENCODE_CHAR_NUM;
        tmp = sk[i];
        sk[i] = sk[j];//交换s[x]和s[y]
        sk[j] = tmp;
        t = (sk[i] + sk[j]) % ENCODE_CHAR_NUM;
        Data[k] ^= sk[t];
    }
}
