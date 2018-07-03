/*
 * Global.h
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */

#ifndef GLOBAL_H_
#define GLOBAL_H_

#define AppVer      1

#define u8_t        unsigned char
#define u16_t       unsigned short
#define u32_t       unsigned int
#define s8_t        signed char
#define s16_t       signed short
#define s32_t       signed int

#define msleep(x) usleep(x*1000)
#define APP_LOG( format, ... )   printf( format, ##__VA_ARGS__ )

#define BASE_CHAR_LEN   32
#define CMD_MAX_LEN     31
#define VALID_DATA_LEN 	20
#define CHAR_BUF_LEN   1024

#define SOUND_RATE          44100   /* 采样频率 */
#define SOUND_SIZE          16      /* 量化位数 */
#define SOUND_CHANNELS      1 		/* 声道数目  1= 单声道 2= 立体声*/
#define HEIGHT_BASE_FREQ    18088  /*高频基础频率*/
#define MIDDLE_BASE_FREQ    14298  /*中频基础频率*/
#define LOWPOWER_GUIDE_FREQ	16538  /*低功耗导码频率*/
#define SOUND_MAX_VAL        32767

#define CONFIG_CRYPT_KEY	"OIk,heT&*4sd$2gU"
#define CRYPT_LEN		16

#ifndef PI
#define PI             (3.14159265f)
#endif

#include <stdio.h>

#define TAG "SNDApi_jni" // 这个是自定义的LOG的标识
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,TAG ,__VA_ARGS__) // 定义LOGD类型
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,TAG ,__VA_ARGS__) // 定义LOGI类型
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,TAG ,__VA_ARGS__) // 定义LOGW类型
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,TAG ,__VA_ARGS__) // 定义LOGE类型
#define LOGF(...) __android_log_print(ANDROID_LOG_FATAL,TAG ,__VA_ARGS__) // 定义LOGF类型

class Global {
public:
	Global();
	virtual ~Global();
	static int HGuideFreqI;
	static int MGuideFreqI;
//	static float BaseFreqHr;        //字母之间的频率间隔
	static int FreqHrHalf;      //频率间隔的一半

//	static int HBaseFreq[BASE_CHAR_LEN] ;   //对应字母的高频率
//	static int MBaseFreq[BASE_CHAR_LEN] ;   //对应字母的中频率
	static float SmoothPara[CHAR_BUF_LEN/10];	//平滑数据参数
	static void initData();
	static int getIndex(char c);
	static void charToByte(char *str,int len);	//把对应的字母转换成32进制
	static void byteToChar(char *str,int len);	//把对应的32进制转换成字母
//	static char getHFreqChar(int freq);     //获得高频对应的字母
//	static char getMFreqChar(int freq);     //获得中频对应的字母
	static int getHFreqI(int index);     	//获得高频对应字母的FFT索引
	static int getMFreqI(int index);     	//获得中频对应字母的FFT索引
	static int getCharHFreq(char c);		//获得某个字母的高频频率
	static int getCharMFreq(char c);		//获得某个字母的中频频率

private:

	static char BaseChar[BASE_CHAR_LEN];    //基本字符
	static int MFreqI[BASE_CHAR_LEN];
	static int HFreqI[BASE_CHAR_LEN];
	static int LMFreqP[BASE_CHAR_LEN];
	static int LHFreqP[BASE_CHAR_LEN];
	static int SMFreqP[BASE_CHAR_LEN];
	static int SHFreqP[BASE_CHAR_LEN];
	static float FreqHr;
};

#endif /* GLOBAL_H_ */
