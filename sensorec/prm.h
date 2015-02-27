//
//  prm.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-10.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#ifndef __sensorec__prm__
#define __sensorec__prm__

#include <stdio.h>

#define SAMPLE_RATE 25

#define LP_EVER -10000,0,0
#define LP_NOW -1,0

#define LP_INIT 1
#define LP_PUSH 2
#define LP_GET 3
#define LP_GET_INCREASE 4
#define LP_GET_DECREASE 5
#define LP_GET_LARGEST_INCREASE 6
#define LP_GET_LARGEST_DECREASE 7
#define LP_GET_LARGEST_ANGLE    8
#define LP_GET_SMALLEST_ANGLE   9
#define LP_GET_ANGLE_CHANGE     10
#define LP_GET_LRANGLE_CHANGE   11
#define LP_GET_LR               12


#define DEG(x) ((x)*(180.0/M_PI))
#define RAD(x) ((x)*(M_PI/180.0))
#define UNUSED(x) (void)(x)
#define SIGN(x) ((x)>=0?1:-1)
//#define abs(x) ((x)>=0?(x):(-(x)))
#define SQR(x) ((x)*(x))
#define BOUND(x,a,b) { if ((x) > (b)) (x) = (b); if ((x) < (a)) (x) = (a); }
#define MMAX(a,b) ((a)>(b)?(a):(b))

// Loop abbreviations
#define ILOOP(N) for(i=0;i<(N);i++)
#define JLOOP(N) for(j=0;j<(N);j++)
#define RLOOP(N) for(r=0;r<(N);r++)
#define CLOOP(N) for(c=0;c<(N);c++)
#define CALIBTIMEOUT 3.0

// A 3D rotation matrix
typedef struct lp_matrix {
    float m[3][3];
} LP_matrix;

extern int g_count;
extern float g_bp;

//---------------------------------
int angle (int action
           ,int n1
           ,int n2
           ,float angle_in
           ,float lrangle_in
           ,float *angle_out);
//---------------------------------
// Entry point for all operations relating to angle buffer.
// In C because it will end up on a microcontroller eventually.

//---------------
void angle_test();
//---------------
// Unit test for angle buffer operations

//-------------------------------------------------------------
float lp_displacement (float bg, float rat_y_z, uint32_t *len);
//-------------------------------------------------------------
// Segment the sequence of bg values, return max displacement
// of previous segment when a new one starts.
// If no new segment, return 0.
// bg = sqrt (x*x + y*y + z*z) - GRAVITY;
// rat_y_z = ABS(y/z)
// *len is set to the segment length in samples

//-----------------------------------------
void transpose (LP_matrix *p_m, LP_matrix *p_res);
//-----------------------------------------
// Transpose a matrix


//-----------------------------------------------------
void matmul (LP_matrix *p_m1, LP_matrix *p_m2, LP_matrix *p_res);
//-----------------------------------------------------
// Multiply two 3x3 matrices

//-----------------------------------------------------
void matxvec (LP_matrix *p_m, float *p_v, float *p_res);
//-----------------------------------------------------
// Multiply a matrix M with vector v

//-------------------------------------------
float getFbangle (float x, float y, float z);
//-------------------------------------------
// Get pelvic angle


//-------------------------------------------
float getLrangle (float x, float y, float z);
//-------------------------------------------
// Get left/right lean angle

//---------------------------
float lp_bworth_bandpass_2_5 (float p_y);
//---------------------------
// Butterworth bandpass 2 to 5 Hertz
// This assumes a sampling rate of 25
// Used for g_bp
// WARNING: Must be called exactly once per sample.

//---------------------------
float lp_bworth_lowpass_05 (float p_y);
//---------------------------
// Butterworth lowpass 0.5 Hz
// This assumes a sampling rate of 25
// Used for g_bp
// WARNING: Must be called exactly once per sample.


#endif /* defined(__sensorec__prm__) */
