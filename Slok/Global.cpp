/*
 * Global.cpp
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include<math.h>
#include "Global.h"

char Global::BaseChar[] = {'0','1','2','3','4','5','6','7','8','9',
			'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q',
			'r','s','t','u','v'};//,'w','x','y','z'};

int Global::MFreqI[] = {337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368};
int Global::HFreqI[] = {425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456};
float Global::FreqHr = 43.0664f;
int Global::HGuideFreqI = 420;
int Global::MGuideFreqI = 332;

//int Global::HBaseFreq[BASE_CHAR_LEN] {18324,18367,18410,18453,18496,18540,18583,18626,18669,18712,18755,18798,18841,18884,18927,18970,19013,19056,19099,19142,19186,19229,19272,19315,19358,19401,19444,19487,19530,19573,19616,19659};
//int Global::MBaseFreq[BASE_CHAR_LEN] {14534,14577,14621,14664,14707,14750,14793,14836,14879,14922,14965,15008,15051,15094,15137,15180,15223,15267,15310,15353,15396,15439,15482,15525,15568,15611,15654,15697,15740,15783,15826,15869};


//int Global::HBaseFreq[BASE_CHAR_LEN] {18303,19294,18519,18734,18389,18992,18475,19208,19423,19078,19552,18863,19165,19035,19595,18691,19509,18906,18648,18346,18562,19251,19380,18605,19121,18949,19466,18820,18777,19337,18432,19638};
//int Global::MBaseFreq[BASE_CHAR_LEN] {14513,15461,15332,14686,15073,14772,14815,15418,14600,15676,14556,14729,14901,15289,15805,15762,15633,15719,14858,15375,14987,15030,14944,15202,15159,15590,15116,15504,15246,15547,14643,15848};
//float Global::BaseFreqHr = (float)SOUND_RATE / (float)CHAR_BUF_LEN ;
int Global::FreqHrHalf =  (int)Global::FreqHr/2-1;
float Global::SmoothPara[CHAR_BUF_LEN/10];
Global::Global() {
	// TODO Auto-generated constructor stub
}

Global::~Global() {
	// TODO Auto-generated destructor stub
}

//初始化频率数据
void Global::initData()
{
    memset(Global::SmoothPara,0,sizeof(float)*(CHAR_BUF_LEN/10));
    float nangular = (float)180/(CHAR_BUF_LEN/10);
    for (int ii=0;ii<CHAR_BUF_LEN/10;ii++) {
    	Global::SmoothPara[ii] = (float)(cos(nangular*ii*PI/180)+1)/2;
    }
}
int Global::getIndex(char c)
{
    for(int ii=0;ii<BASE_CHAR_LEN;ii++)
    {
        if(c==Global::BaseChar[ii])
        {
            return ii;
        }
    }
    return 0;
}
//把对应的字母转换成32进制
void Global::charToByte(char *str,int len)
{
	for(int ii=0;ii<len;ii++)
	{
		str[ii]=getIndex(str[ii]);
	}
}
//把对应的32进制转换成字母
void Global::byteToChar(char *str,int len)
{
	for(int ii=0;ii<len;ii++)
	{
		str[ii]=Global::BaseChar[str[ii]%BASE_CHAR_LEN];
	}
}
//获得高频对应的字母
//char Global::getHFreqChar(int freq)
//{
//    if(freq<(Global::HBaseFreq[0]-Global::BaseFreqHrHalf)||freq>(Global::HBaseFreq[BASE_CHAR_LEN-1]+Global::BaseFreqHrHalf))
//        return 0;
//    for(int i=0;i<BASE_CHAR_LEN;i++)
//    {
//        if(abs(Global::HBaseFreq[i]-freq)<Global::BaseFreqHrHalf)
//        {
//            return Global::BaseChar[i];
//        }
//    }
//    return 0;
//}
////获得中频对应的字母
//char Global::getMFreqChar(int freq)
//{
//    if(freq<(Global::MBaseFreq[0]-Global::BaseFreqHrHalf)||freq>(Global::MBaseFreq[BASE_CHAR_LEN-1]+Global::BaseFreqHrHalf))
//        return 0;
//    for(int i=0;i<BASE_CHAR_LEN;i++)
//    {
//        if(abs(Global::MBaseFreq[i]-freq)<Global::BaseFreqHrHalf)
//        {
//            return Global::BaseChar[i];
//        }
//    }
//    return 0;
//}
//获得高频对应字母的FFT索引
int Global::getHFreqI(int index)
{
	return Global::HFreqI[index];
}
//获得中频对应字母的FFT索引
int Global::getMFreqI(int index)
{
	return Global::MFreqI[index];
}

//获得某个字母的高频频率
int Global::getCharHFreq(char c)
{
	if(c=='z')
	{
		return Global::HGuideFreqI*FreqHr+2;
	}
    for(int ii=0;ii<BASE_CHAR_LEN;ii++)
    {
        if(Global::BaseChar[ii]==c)
        {
        	return Global::HFreqI[ii]*FreqHr+2;
        }
    }
    return 0;
}
//获得某个字母的中频频率
int Global::getCharMFreq(char c)
{
	if(c=='z')
	{
		return Global::MGuideFreqI*FreqHr+2;
	}
    for(int ii=0;ii<BASE_CHAR_LEN;ii++)
    {
        if(Global::BaseChar[ii]==c)
        {
        	return Global::MFreqI[ii]*FreqHr+5;
        }
    }
    
    return 0;
}


