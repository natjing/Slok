/*
 * SoundMake.h
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */

#ifndef SOUNDMAKE_H_
#define SOUNDMAKE_H_

#include "Rscode.h"
class SoundMake {
public:
	SoundMake();
	virtual ~SoundMake();
	/*
	 *字符串生成音频数据
	 *str    :生成音频数据的字符串
	 *len    :字符串长度
	 *data   :存放音频的buf
	 *tag    :叠加音频标识
	 *返回     :成生的数据长度
	 */
	int getStrtoBuf(char const *str, int len, short *data, int tag,int cbuflen);
	int getLPStrtoBuf(char const *str, int len, short *data, int tag,int cbuflen);
	int getTestStrtoBuf(char const *str,int len,short *buffer,int tag,int cbuflen);
	int convertPcm2Wav(char const *src_file, char const *dst_file, int channels, int sample_rate);
	/*
	 *音频数据转换成字符串
	 *str    :音频数据
	 *len    :音频数据长度
	 *data   :解析后的字符串
	 *返回 :解后的字符串长度
	 */
	int getBuftoStr(short *data, int len, char *str);
	/*
	 * 分析蜂鸣器回馈代码
	 * */
	int getCallBackCode(short *data, int len);
private:
    Rscode rsCode;
    int EncodeStr(char const *str,int len,char *tCmd);	//生成要产生音频的字符串
    void getSinWave(int hfreq,int mfreq,int len,int rate,short *data); //生成某个频率的音频数据
    void getSSinWave(int freq,int len,int rate,short *data,int maxval); //生成某个频率的音频数据
	void mergeData(short *sData,int slen,short *aData,int alen,int kw,int seglen);   //合并两个频率数据
	void smoothData(short *data,int len,int seglen);   //平滑数据
	void smoothDataHE(short *data,int len,int seglen);	//平滑首尾数据

	bool checkHeadFreq(int mfreq,int hfreq);     //判断是否为头部频率
	void getMakeWave(char *str,int len,short *data); //字符串生成音频数据
	int getCharFreq(char c,bool isH);     //获得字母对应的频率

	void makeTimeStamp (char *data,bool isSec);	//生成时间戳
	char makeVeriCode (char *data,int len);		//生成校验码
};

#endif /* SOUNDMAKE_H_ */
