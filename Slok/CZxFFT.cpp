//
// Created by Administrator on 2017/2/21.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "Global.h"
#include "CZxFFT.h"

const float sin_tb[] = {  // 精度(PI PI/2 PI/4 PI/8 PI/16 ... PI/(2^k))
0.000000, 1.000000, 0.707107, 0.382683, 0.195090, 0.098017,
0.049068, 0.024541, 0.012272, 0.006136, 0.003068, 0.001534,
0.000767, 0.000383, 0.000192, 0.000096, 0.000048, 0.000024,
0.000012, 0.000006, 0.000003
};


const float cos_tb[] = {  // 精度(PI PI/2 PI/4 PI/8 PI/16 ... PI/(2^k))
-1.000000, 0.000000, 0.707107, 0.923880, 0.980785, 0.995185,
0.998795, 0.999699, 0.999925, 0.999981, 0.999995, 0.999999,
1.000000, 1.000000, 1.000000, 1.000000 , 1.000000, 1.000000,
1.000000, 1.000000, 1.000000
};

CZxFFT::CZxFFT()
{
    //ctor
}

CZxFFT::~CZxFFT()
{
    //dtor
}
/*
 * @brief   计算二进制表示中1出现的个数的快速算法.
 *          有c个1，则循环c次
 * @inputs
 * @outputs
 * @retval
 */
int CZxFFT::ones_32(int n)
{
    unsigned int c =0 ;
    for (c = 0; n; ++c)
    {
        n &= (n -1) ; // 清除最低位的1
    }
    return c ;
}
/*
 * @brief
 *   floor{long2(x)}
 *   x must > 0
 * @inputs
 * @outputs
 * @retval
 */
int CZxFFT::floor_log2_32(int x)
{
    x |= (x>>1);
    x |= (x>>2);
    x |= (x>>4);
    x |= (x>>8);
    x |= (x>>16);
    return (ones_32(x>>1));
}
/*
 * FFT Algorithm
 * === Inputs ===
 * x : complex numbers
 * N : nodes of FFT. @N should be power of 2, that is 2^(*)
 * === Output ===
 * the @x contains the result of FFT algorithm, so the original data
 * in @x is destroyed, please store them before using FFT.
 */
void CZxFFT::FastFourier(TYPE_FFT *x, int N)
{
	int i,j,l,k,ip;
	u32_t M = 0;
	int le,le2;
	TYPE_FFT_E sR,sI,tR,tI,uR,uI;

	M = floor_log2_32(N);

	/*
	 * bit reversal sorting
	 */
	l = N >> 1;
	j = l;
    ip = N-2;
    for (i=1; i<=ip; i++) {
        if (i < j) {
            tR = x[j].real;
			tI = x[j].imag;
            x[j].real = x[i].real;
			x[j].imag = x[i].imag;
            x[i].real = tR;
			x[i].imag = tI;
		}
		k = l;
		while (k <= j) {
            j = j - k;
			k = k >> 1;
		}
		j = j + k;
	}
	/*
	 * For Loops
	 */
	for (l=1; l<=M; l++) {   /* loop for ceil{log2(N)} */
		//le = (int)pow(2,l);
		le  = (int)(1 << l);
		le2 = (int)(le >> 1);
		uR = 1;
		uI = 0;

        k = floor_log2_32(le2);
        sR = cos_tb[k]; //cos(PI / le2);
        sI = -sin_tb[k];  // -sin(PI / le2)
		for (j=1; j<=le2; j++) {   /* loop for each sub DFT */
			//jm1 = j - 1;
			for (i=j-1; i<N; i+=le) {  /* loop for each butterfly */
				ip = i + le2;
				tR = x[ip].real * uR - x[ip].imag * uI;
				tI = x[ip].real * uI + x[ip].imag * uR;
				x[ip].real = x[i].real - tR;
				x[ip].imag = x[i].imag - tI;
				x[i].real += tR;
				x[i].imag += tI;
			}  /* Next i */
			tR = uR;
			uR = tR * sR - uI * sI;
			uI = tR * sI + uI *sR;
		} /* Next j */
	} /* Next l */
}
int CZxFFT::getAlignLen(int d_len)
{
    return  (int)pow(2.0, ceil(log((float)d_len)/log(2.0)));
}
void CZxFFT::IFFT(TYPE_FFT *x, int N)
{
	int k = 0;
	for (k=0; k<=N-1; k++) {
		x[k].imag = -x[k].imag;
	}
	FastFourier(x, N);    /* using FFT */
	for (k=0; k<=N-1; k++) {
		x[k].real = x[k].real / N;
		x[k].imag = -x[k].imag / N;
	}
}
void CZxFFT::FFT(short * src,int src_len,TYPE_FFT * dst)
{
    memset(&dst,0,sizeof(COMPLEX)*src_len);
    for (int i=0;i<src_len;i++ )
    {
        dst[i].real = src[i];
        dst[i].imag  = 0.0f;
    }
    FastFourier(dst,src_len);
}
int CZxFFT::getMaxFreq(short * src,int src_len, unsigned int rate)
{
    COMPLEX x[src_len];
    memset(&x,0,sizeof(COMPLEX)*src_len);
    for (int i=0;i<src_len;i++ )
    {
        x[i].real = src[i];
        x[i].imag  = 0.0f;
    }
    FastFourier(x,src_len);
    int k =0 ;
    TYPE_FFT_E wt,th;
    wt = POW(x[k].real) + POW(x[k].imag);
	for (int i = 1; i < src_len/2; i ++) {
		th = POW(x[i].real) + POW(x[i].imag);
		if (th > wt) {
			k = i;
			wt = th;
		}
	}
	int freq = (unsigned int)round((float)k * ((float)rate / (float)src_len));
    return freq;
}
int CZxFFT::getMaxFreqI(short * src,int src_len, unsigned int rate,int starti,int endi)
{
	COMPLEX x[src_len];
	memset(&x,0,sizeof(COMPLEX)*src_len);
	for (int i=0;i<src_len;i++ )
	{
		x[i].real = src[i];
		x[i].imag  = 0.0f;
	}
	FastFourier(x,src_len);
	int k =starti ;
	TYPE_FFT_E wt,th;
	wt = POW(x[k].real) + POW(x[k].imag);
	for (int i = starti+1; i < endi; i ++) {
		th = POW(x[i].real) + POW(x[i].imag);
		if (th > wt) {
			k = i;
			wt = th;
		}
	}
	return k;
}
bool CZxFFT::checkDualFreq(short * src,int src_len, unsigned int rate,int *freqi)
{
    int NFFT =getAlignLen(src_len);
    COMPLEX dst[NFFT];
    memset(&dst,0,sizeof(COMPLEX)*NFFT);
    for (int i=0;i<src_len;i++ )
    {
        dst[i].real = src[i];
        dst[i].imag  = 0.0f;
    }
    FastFourier(dst,NFFT);
    float freqhr = (float)rate / (float)NFFT;
    float bmhv,mmhv,hmhv,tmv;
    int smi=Global::getMFreqI(0);
    int emi=Global::getMFreqI(BASE_CHAR_LEN-1);
    int shi=Global::getHFreqI(0);
    int ehi=Global::getHFreqI(BASE_CHAR_LEN-1);
    int mi=0,hi=0;
    mmhv = 0;
    for(int i=smi-1;i<emi+1;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > mmhv) {
            mi = i;
			mmhv = tmv;
		}
    }
    hmhv = 0;
    for(int i=shi-1;i<ehi+1;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > hmhv) {
            hi = i;
			hmhv = tmv;
		}
    }
    freqi[0] = mi;
    freqi[1] = hi;
    if(mi||hi)
    {
        return true;
    }
    else
    {
        return false;
    }
}
bool CZxFFT::checkGuideFreq(short * src,int src_len, unsigned int rate)
{
    int NFFT =getAlignLen(src_len);
    COMPLEX dst[NFFT];
    memset(&dst,0,sizeof(COMPLEX)*NFFT);
    for (int i=0;i<src_len;i++ )
    {
        dst[i].real = src[i];
        dst[i].imag  = 0.0f;
    }
    FastFourier(dst,NFFT);
    float freqhr = (float)rate / (float)NFFT;
    float bmhv,mmhv,hmhv,tmv;
    int smi=round(MIDDLE_BASE_FREQ/freqhr);
    int emi=Global::getMFreqI(BASE_CHAR_LEN-1);
    int shi=round(HEIGHT_BASE_FREQ/freqhr);
    int ehi=Global::getHFreqI(BASE_CHAR_LEN-1);
    int mi=0,hi=0;
    bmhv = POW(dst[0].real) + POW(dst[0].imag);
    for(int i=1;i<smi-2;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > bmhv) {
			bmhv = tmv;
		}
    }
    mmhv = bmhv/50;
    for(int i=smi-2;i<emi+1;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > mmhv) {
            mi = i;
			mmhv = tmv;
		}
    }
    hmhv = bmhv/100;
    for(int i=shi-2;i<ehi+1;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > hmhv) {
            hi = i;
			hmhv = tmv;
		}
    }
    if(mi == smi||hi==shi)
    {
        return true;
    }
    else
    {
        return false;
    }
}
//判断首字母频率 0失败 1引导频率 2首字母频率
int CZxFFT::checkFirstCharFreq(short * src,int src_len, unsigned int rate)
{
    int NFFT = getAlignLen(src_len);
    COMPLEX dst[NFFT];
    memset(&dst,0,sizeof(COMPLEX)*NFFT);
    for (int i=0;i<src_len;i++ )
    {
        dst[i].real = src[i];
        dst[i].imag  = 0.0f;
    }
    FastFourier(dst,NFFT);
    float freqhr = (float)rate / (float)NFFT;
    float bmhv,mmhv,hmhv,tmv;
    int smi=round(MIDDLE_BASE_FREQ/freqhr);
    int emi=Global::getMFreqI(BASE_CHAR_LEN-1);
    int shi=round(HEIGHT_BASE_FREQ/freqhr);
    int ehi=Global::getHFreqI(BASE_CHAR_LEN-1);
    int mi=0,hi=0;
    bmhv = POW(dst[0].real) + POW(dst[0].imag);
    for(int i=1;i<smi-2;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > bmhv) {
			bmhv = tmv;
		}
    }
    mmhv = bmhv/100;
    for(int i=smi-2;i<emi+1;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > mmhv) {
            mi = i;
			mmhv = tmv;
		}
    }
    hmhv = bmhv/1000;
    for(int i=shi-2;i<ehi+1;i++)
    {
        tmv = POW(dst[i].real) + POW(dst[i].imag);
		if (tmv > hmhv) {
            hi = i;
			hmhv = tmv;
		}
    }
    if (mi == smi)
    {
        mi = 1;
    }
    else if(mi>emi-2)
    {
        mi = 2;
    }

    if (hi == shi)
    {
        hi = 1;
    }
    else if(hi>ehi-2)
    {
        hi = 2;
    }
    if((mi==1&&hi!=2)||(mi!=2&&hi==1))
    {
        return 1;
    }
    else if((mi==2&&hi!=1)||(mi!=1&&hi==2))
    {
        return 2;
    }
    else
    {
        return 0;
    }
}
int CZxFFT::checkCallFreqI(short * src,int src_len, unsigned int rate)
{
    COMPLEX x[src_len];
    memset(&x,0,sizeof(COMPLEX)*src_len);
    for (int i=0;i<src_len;i++ )
    {
        x[i].real = src[i];
        x[i].imag  = 0.0f;
    }
    FastFourier(x,src_len);
    int k = 0 ;
    TYPE_FFT_E wt,th;
    for (int i = 20; i < 160; i ++) {
        th = POW(x[i].real) + POW(x[i].imag);
        if (th > wt) {
            wt = th;
        }
    }
    wt = wt/2;
    for (int i = 70; i < 83; i ++) {
        th = POW(x[i].real) + POW(x[i].imag);
        if (th > wt&& th>4000) {
            k = i;
            wt = th;
        }
    }
    return k;
}
