/*
 * SoundMake.cpp
 *
 *  Created on: 2017-3-2
 *      Author: Administrator
 */
#include <cstdlib>
#include <ctime>
#include <math.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "Rc4_20.h"
#include "Global.h"
#include "SoundMake.h"
#include "CZxFFT.h"

SoundMake::SoundMake() {
	Global::initData();
}

SoundMake::~SoundMake() {
	// TODO Auto-generated destructor stub
}
int SoundMake::EncodeStr(char const *str,int len,char *tCmd)
{
	int DATA_LEN = 13;
	int tmpI = len;
    char sCmd[CMD_MAX_LEN+1];
    memset(sCmd,0,sizeof(sCmd));
    sCmd[0]='v';
    if(len>DATA_LEN)
    	tmpI = DATA_LEN;
    memcpy(sCmd+1,str,tmpI);
	//LOGD("SoundMake::getStrtoBuf:%s",sCmd);
    Global::charToByte(sCmd,CMD_MAX_LEN);
    makeTimeStamp(sCmd+14,true);
    tmpI = makeVeriCode(sCmd,20);
    sCmd[20] = tmpI&0x1F;
    memcpy(tCmd,sCmd,CMD_MAX_LEN);
    Global::byteToChar(tCmd,CMD_MAX_LEN);
    //LOGD("rsCode.Encode targStr:%s  VCode:%d ",tCmd,tmpI&0x1F);

    Rc4_20::Crypt((sCmd+1), DATA_LEN+7);
    int tcmdLen = rsCode.encode(sCmd,CMD_MAX_LEN,tCmd);
    Global::byteToChar(sCmd,CMD_MAX_LEN);
    Global::byteToChar(tCmd,CMD_MAX_LEN);
 //   LOGD("rsCode.Encode len:%d  sourStr:%s targStr:%s  VCode:%d ",tcmdLen,sCmd,tCmd,tmpI&0x1F);
    return tcmdLen;
}


//字符串生成音频数据
int SoundMake::getStrtoBuf(char const *str,int len,short *buffer,int tag,int cbuflen)
{
	int dataBufLen = (CMD_MAX_LEN+6)*cbuflen;
    char tCmd[CMD_MAX_LEN+1];
    memset(tCmd,0,sizeof(tCmd));
    int tcmdLen = EncodeStr(str,len,tCmd);
    SoundMake::getSinWave(Global::getCharHFreq('z'),Global::getCharMFreq('z'),cbuflen*4,SOUND_RATE,buffer+cbuflen);
    smoothDataHE(buffer+cbuflen,cbuflen*4,cbuflen);
    for(int i=0;i<tcmdLen;i++)
    {
    	SoundMake::getSinWave(Global::getCharHFreq(tCmd[i]),Global::getCharMFreq(tCmd[i]),cbuflen,SOUND_RATE,buffer+(5+i)*cbuflen);
    }
    smoothData(buffer+cbuflen*4,dataBufLen-cbuflen*4,cbuflen);
    if(tag>0)
    {
    	srand((unsigned)time(0));
    	int abufLen = (tcmdLen-1)*cbuflen;
    	short abuffer[abufLen];
    	int tf,ts,tts;
		for (int ii = 0; ii < tcmdLen;) {
			tf = (int) (rand() % 3 + 1);
			ts = (int) (rand() % 5 + 10);
			if(cbuflen<CHAR_BUF_LEN)
			{
				ts *=(CHAR_BUF_LEN/cbuflen);
			}
			tts=ts;
			if(ii+tts>=tcmdLen)
			{
				tts=tcmdLen-ii-1;
			}
			int bufLen = tts*cbuflen;
			SoundMake::getSSinWave(tf*1000,bufLen,SOUND_RATE,abuffer+ii*cbuflen,SOUND_MAX_VAL);
			smoothDataHE(abuffer+ii*cbuflen,bufLen,cbuflen);
			ii += ts;
		}
		SoundMake::mergeData(buffer+6*cbuflen,abufLen,abuffer,abufLen,80,cbuflen);
    }
    return 0;
}
//字符串生成音频数据
int SoundMake::getLPStrtoBuf(char const *str,int len,short *buffer,int tag,int cbuflen)
{
	int dataBufLen = (CMD_MAX_LEN+6)*cbuflen;
	char tCmd[CMD_MAX_LEN+1];
	memset(tCmd,0,sizeof(tCmd));
	int tcmdLen = EncodeStr(str,len,tCmd);
    SoundMake::getSinWave(Global::getCharHFreq('z'),Global::getCharMFreq('z'),cbuflen*4,SOUND_RATE,buffer+cbuflen);
    smoothDataHE(buffer+cbuflen,cbuflen*4,cbuflen);
    for(int i=0;i<tcmdLen;i++)
    {
    	SoundMake::getSinWave(Global::getCharHFreq(tCmd[i]),Global::getCharMFreq(tCmd[i]),cbuflen,SOUND_RATE,buffer+(5+i)*cbuflen);
    }
    smoothData(buffer+cbuflen*4,dataBufLen-cbuflen*4,cbuflen);
    if(tag>0)
    {
    	srand((unsigned)time(0));
    	int abufLen = (tcmdLen-1)*cbuflen;
    	short abuffer[abufLen];
    	int tf,ts,tts;
		for (int ii = 0; ii < tcmdLen;) {
			tf = (int) (15+rand() % 10);
			ts = (int) (rand() % 5 + 10);
			if(cbuflen<CHAR_BUF_LEN)
			{
				ts *=(CHAR_BUF_LEN/cbuflen);
			}
			tts=ts;
			if(ii+tts>=tcmdLen)
			{
				tts=tcmdLen-ii-1;
			}
			int bufLen = tts*cbuflen;
			SoundMake::getSSinWave(tf*100,bufLen,SOUND_RATE,abuffer+ii*cbuflen,SOUND_MAX_VAL);
			smoothDataHE(abuffer+ii*cbuflen,bufLen,cbuflen);
			ii += ts;
		}
		SoundMake::mergeData(buffer+6*cbuflen,abufLen,abuffer,abufLen,90,cbuflen);
    }
    return 0;
}

//音频数据转换成字符串
int SoundMake::getBuftoStr(short *data,int len,char *str)
{
    return 0;
}
// 分析蜂鸣器回馈代码
int SoundMake::getCallBackCode(short *data, int len)
{
	int tmpBurLen = 1024;
	CZxFFT fft;
	int reVal = -1,hcnum = 0;
	int index = 0;
	short fipool[10];
	short tmpbuf[tmpBurLen];
	memset(fipool,0,sizeof(short)*10);
	while ((index + tmpBurLen) <= len) {
		memset(tmpbuf,0,sizeof(short)*tmpBurLen);
		memcpy(tmpbuf,data+index,sizeof(short)*tmpBurLen);
		index += tmpBurLen;
		int di = fft.checkCallFreqI(tmpbuf,tmpBurLen, 44100);
		if(di==72||di==71||di==73)
		{
		    hcnum++;
		}
		else if(di>=74 && di<83)
		{
			fipool[di-74]++;
		}
	}
	if(hcnum>2)
	{
        int tMax = 0;
        for(int i=0;i<10;i++)
        {
            if(fipool[i]>tMax)
            {
                tMax = fipool[i];
                reVal = i;
            }
        }
	}
	//LOGD("getCallBackCode hcode:%d  reVal:%d  p0:%d p1:%d  p2:%d  p3:%d  p4:%d  p5:%d  p6:%d  p7:%d  p8:%d  p9:%d",hcnum,reVal
	//,fipool[0],fipool[1],fipool[2],fipool[3],fipool[4],fipool[5],fipool[6],fipool[7],fipool[8],fipool[9]);
	return reVal;
}
//测试字符串生成音频数据
int SoundMake::getTestStrtoBuf(char const *str,int len,short *buffer,int tag,int cbuflen)
{
	int tcmdLen = 31;
	int revFreq = 20;
	int dataBufLen = (CMD_MAX_LEN+6)*cbuflen;
	char tCmd[CMD_MAX_LEN+1];
	memset(tCmd,0,sizeof(tCmd));
	memcpy(tCmd,str,CMD_MAX_LEN);
    SoundMake::getSinWave(Global::getCharHFreq('z'),Global::getCharMFreq('z'),cbuflen*4,SOUND_RATE,buffer+cbuflen);
    for(int i=0;i<tcmdLen;i++)
    {
    	SoundMake::getSinWave(Global::getCharHFreq(tCmd[i]),Global::getCharMFreq(tCmd[i]),cbuflen,SOUND_RATE,buffer+(5+i)*cbuflen);
    }
    smoothData(buffer,dataBufLen,cbuflen);
    if(tag>0)
    {
    	srand((unsigned)time(0));
    	int abufLen = (tcmdLen-1)*cbuflen;
    	short abuffer[abufLen];
    	int tf,ts,tts;
		for (int ii = 0; ii < tcmdLen;) {
			tf = (int) (rand() % 3 + 1);
			ts = (int) (rand() % 5 + 10);
			if(cbuflen<CHAR_BUF_LEN)
			{
				ts *=(CHAR_BUF_LEN/cbuflen);
			}
			tts=ts;
			if(ii+tts>=tcmdLen)
			{
				tts=tcmdLen-ii-1;
			}
			int bufLen = tts*cbuflen;
			SoundMake::getSSinWave(tf*1000,bufLen,SOUND_RATE,abuffer+ii*cbuflen,SOUND_MAX_VAL);
			smoothDataHE(abuffer+ii*cbuflen,bufLen,cbuflen);
			ii += ts;
		}
		SoundMake::mergeData(buffer+6*cbuflen,abufLen,abuffer,abufLen,80,cbuflen);
    }
    return 0;
}

//生成某个频率的双音频数据
void SoundMake::getSinWave(int hfreq,int mfreq,int len,int rate,short *data)
{
    int ii=0;
    float hangular = (float) (2*PI*hfreq)/rate;
    float mangular = (float) (2*PI*mfreq)/rate;
    for(ii=0;ii<len;ii++)
    {
        data[ii] = (short) (SOUND_MAX_VAL*((float)sin(hangular*(ii))));
        data[ii] = data[ii]/2 + ((short) (SOUND_MAX_VAL*((float)sin(mangular*(ii)))))/2;
    }
}
//生成某个频率的音频数据
void SoundMake::getSSinWave(int freq,int len,int rate,short *data,int maxval)
{
    int ii=0;
    float hangular = (float) (2*PI*freq)/rate;
    for(ii=0;ii<len;ii++)
    {
        data[ii] = (short) (maxval*((float)sin(hangular*(ii))));
    }
}
//合并两个频率数据
void SoundMake::mergeData(short *sData,int slen,short *aData,int alen,int kw,int seglen)
{
    int i=0,f=0;
    for(i=0;i<slen;)
    {
        for(f=0;f<alen;f++,i++)
        {
            int nv = sData[i]*kw/100+aData[f]*(100-kw)/100;
            if(nv>SOUND_MAX_VAL)
            {
                nv = SOUND_MAX_VAL;
            }
            if(nv<-SOUND_MAX_VAL)
            {
                nv=-SOUND_MAX_VAL;
            }
            sData[i] = (short) nv;
        }
        i+= 5*seglen;        //第二次间隔5个字符
    }
}
//平滑数据
void SoundMake::smoothData(short *data,int len,int seglen)
{
    int cLen = len/seglen;
    for(int c=1;c<cLen-1;c++)
    {
    	smoothDataHE(data+c*seglen,seglen,seglen);
    }
}
//平滑首尾数据
void SoundMake::smoothDataHE(short *data,int len,int seglen)
{
    int smoothLen = seglen/2;
    float SmoothPara[smoothLen];
    memset(SmoothPara,0,sizeof(float)*smoothLen);
    float nangular = (float)180/smoothLen;
    for (int ii=0;ii<smoothLen;ii++) {
    	SmoothPara[ii] = (float)(cos(nangular*ii*PI/180)+1)/2;
    }
    for(int ii=0,ff=smoothLen-1;ii<len&&ff>=0;ii++,ff--)
	{
		data[ii] = (short) (data[ii]*SmoothPara[ff]);
	}
	for(int ii=len-smoothLen,ff=0;ii<len&&ff<smoothLen;ii++,ff++)
	{
		data[ii] = (short) (data[ii]*SmoothPara[ff]);
	}
}
//生成时间戳
void SoundMake::makeTimeStamp(char *data,bool isSec)
{
	int tc = 0,len = 0;
	time_t timep;
	struct tm *p;
	time(&timep);
	p = localtime(&timep);
	//LOGD("makeTimeStamp curTime:%d-%d-%d %d:%d:%d",p->tm_year+1900,p->tm_mon+1,p->tm_mday,p->tm_hour,p->tm_min,p->tm_sec);
	if(isSec)
	{       //6位最大表示33.4年  116为2016年
		tc = (((((p->tm_year-116)*12+p->tm_mon+1)*31+p->tm_mday)*24+p->tm_hour)*60+p->tm_min)*60+p->tm_sec;
		len = 6;
	}
	else
	{       //5位最大表示62.6年
		tc = ((((p->tm_year-116)*12+p->tm_mon+1)*31+p->tm_mday)*24+p->tm_hour)*60+p->tm_min;
		len = 5;
	}
	for(int i=0;i<len;i++)
	{
		data[len-i-1]=(char)(tc>>(i*5)&0x1F);
	}
}
//生成校验码
char SoundMake::makeVeriCode (char *data,int len)
{
	char reVal = 0;
    for(int i=0;i<len;i++)
	{
    	reVal += data[i];
	}
    return reVal;
}

typedef  struct  {
    
    char        fccID[4];
    
    int32_t      dwSize;
    
    char        fccType[4];
    
} HEADER;

typedef  struct  {
    
    char        fccID[4];
    
    int32_t      dwSize;
    
    int16_t      wFormatTag;
    
    int16_t      wChannels;
    
    int32_t      dwSamplesPerSec;
    
    int32_t      dwAvgBytesPerSec;
    
    int16_t      wBlockAlign;
    
    int16_t      uiBitsPerSample;
    
}FMT;

typedef  struct  {
    
    char        fccID[4];
    
    int32_t      dwSize;
    
}DATA;
/*
 pcm文件路径，wav文件路径，channels为通道数，手机设备一般是单身道，传1即可，sample_rate为pcm文件的采样率，有44100，16000，8000，具体传什么看你录音时候设置的采样率
 */

int SoundMake::convertPcm2Wav(char const *src_file, char const *dst_file, int channels, int sample_rate)

{
    
    int bits = 16;
    
    //以下是为了建立.wav头而准备的变量
    
    HEADER  pcmHEADER;
    
    FMT  pcmFMT;
    
    DATA  pcmDATA;
    
    unsigned  short  m_pcmData;
    
    FILE  *fp,*fpCpy;
    
    if((fp=fopen(src_file,  "rb"))  ==  NULL) //读取文件
        
    {
        
        printf("open pcm file %s error\n", src_file);
        
        return -1;
        
    }
    
    if((fpCpy=fopen(dst_file,  "wb+"))  ==  NULL) //为转换建立一个新文件
        
    {
        
        printf("create wav file error\n");
        
        return -1;
        
    }
    
    //以下是创建wav头的HEADER;但.dwsize未定，因为不知道Data的长度。
    
    strncpy(pcmHEADER.fccID,"RIFF",4);
    
    strncpy(pcmHEADER.fccType,"WAVE",4);
    
    fseek(fpCpy,sizeof(HEADER),1); //跳过HEADER的长度，以便下面继续写入wav文件的数据;
    
    //以上是创建wav头的HEADER;
    
    if(ferror(fpCpy))
        
    {
        
        printf("error\n");
        
    }
    
    //以下是创建wav头的FMT;
    
    pcmFMT.dwSamplesPerSec=sample_rate;
    
    pcmFMT.dwAvgBytesPerSec=pcmFMT.dwSamplesPerSec*sizeof(m_pcmData);
    
    pcmFMT.uiBitsPerSample=bits;
    
    strncpy(pcmFMT.fccID,"fmt  ", 4);
    
    pcmFMT.dwSize=16;
    
    pcmFMT.wBlockAlign=2;
    
    pcmFMT.wChannels=channels;
    
    pcmFMT.wFormatTag=1;
    
    //以上是创建wav头的FMT;
    
    fwrite(&pcmFMT,sizeof(FMT),1,fpCpy); //将FMT写入.wav文件;
    
    //以下是创建wav头的DATA;  但由于DATA.dwsize未知所以不能写入.wav文件
    
    strncpy(pcmDATA.fccID,"data", 4);
    
    pcmDATA.dwSize=0; //给pcmDATA.dwsize  0以便于下面给它赋值
    
    fseek(fpCpy,sizeof(DATA),1); //跳过DATA的长度，以便以后再写入wav头的DATA;
    
    fread(&m_pcmData,sizeof(int16_t),1,fp); //从.pcm中读入数据
    
    while(!feof(fp)) //在.pcm文件结束前将他的数据转化并赋给.wav;
        
    {
        
        pcmDATA.dwSize+=2; //计算数据的长度；每读入一个数据，长度就加一；
        
        fwrite(&m_pcmData,sizeof(int16_t),1,fpCpy); //将数据写入.wav文件;
        
        fread(&m_pcmData,sizeof(int16_t),1,fp); //从.pcm中读入数据
        
    }
    
    fclose(fp); //关闭文件
    
    pcmHEADER.dwSize = 0;  //根据pcmDATA.dwsize得出pcmHEADER.dwsize的值
    
    rewind(fpCpy); //将fpCpy变为.wav的头，以便于写入HEADER和DATA;
    
    fwrite(&pcmHEADER,sizeof(HEADER),1,fpCpy); //写入HEADER
    
    fseek(fpCpy,sizeof(FMT),1); //跳过FMT,因为FMT已经写入
    
    fwrite(&pcmDATA,sizeof(DATA),1,fpCpy);  //写入DATA;
    
    fclose(fpCpy);  //关闭文件
    
    return 0;
    
}
