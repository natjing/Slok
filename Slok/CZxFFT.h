//
// Created by Administrator on 2017/2/21.
//

#ifndef SOUNDAPP_CZXFFT_H
#define SOUNDAPP_CZXFFT_H



#define TYPE_FFT_E     float    /* Type is the same with COMPLEX member */
#define POW(a) 		((a) * (a))


typedef struct {
    TYPE_FFT_E real;
	TYPE_FFT_E imag;
} COMPLEX;

typedef COMPLEX TYPE_FFT;

class CZxFFT
{
    public:
        CZxFFT();
        virtual ~CZxFFT();
        void IFFT(TYPE_FFT *x, int N);
        int getAlignLen(int d_len);
        void FFT(short *x, int N,TYPE_FFT * dst);
        int getMaxFreq(short * src,int src_len, unsigned int rate);
        int getMaxFreqI(short * src,int src_len, unsigned int rate,int starti,int endi);
        bool checkDualFreq(short * src,int src_len, unsigned int rate,int *freq);
        bool checkGuideFreq(short * src,int src_len, unsigned int rate);
        int checkFirstCharFreq(short * src,int src_len, unsigned int rate);
        int checkCallFreqI(short * src,int src_len, unsigned int rate);
    protected:
    private:
        void FastFourier(TYPE_FFT *x, int N);
        int ones_32(int n);
        int floor_log2_32(int x);
};



#endif //SOUNDAPP_CZXFFT_H
