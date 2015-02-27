//
//  prm.c
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-10.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#include "prm.h"
#include "cfuncs.h"
#include <math.h>

#define ABS(x) ((x)>=0?(x):(-(x)))

int g_count = 0; // counts ticks at SAMPLE_RATE frequency
float g_bp = 0;
static int m_displacement_called = 0;

//-------------------------------------------------------------
float lp_displacement (float bg, float rat_y_z, uint32_t *len)
//-------------------------------------------------------------
// Segment the sequence of bg values, return max displacement
// of previous segment when a new one starts.
// If no new segment, return 0.
// bg = sqrt (x*x + y*y + z*z) - GRAVITY;
// rat_y_z = ABS(y/z)
// *len is set to the segment length in samples
{
    UNUSED(rat_y_z);
#define VBUFSIZE (4 * SAMPLE_RATE)
    static float vbuf[VBUFSIZE]; // Speed buffer
    static int vbufpos;
    static uint32_t seg_age;
    // Ring buffer for speed
#define VBUF_PUSH(x) { vbuf[vbufpos++]=(x); vbufpos %= VBUFSIZE; }
#define VBUF_GET(i) ((vbufpos+(i)) >= 0 ? vbuf[((vbufpos+(i))%VBUFSIZE)]\
                                        : vbuf[VBUFSIZE+vbufpos+(i)])
    
    static float v;
    static float bgbuf[3];
    static uint8_t bad_cut;
    static int direction = 0;
    static int prev_direction = 1;
    
    int i;
    
    if (!m_displacement_called) {
        m_displacement_called = 1;
        v = 0;
        vbufpos = 0;
        ILOOP(VBUFSIZE) { vbuf[i] = bg / SAMPLE_RATE; /* fbuf[i] = 0;*/ }
        seg_age = 0;
        bgbuf[0] = 0; bgbuf[1] = 0; bgbuf[2] = 0;
        bad_cut = 0;
    }
    bgbuf[0] = bgbuf[1]; bgbuf[1] = bgbuf[2]; bgbuf[2] = bg;
    float displacement = 0;
    v += bg / SAMPLE_RATE; // speed
    
    // Detect direction change
    if (v > 10) {
        direction = 1; // UP
    }
    else if (v < -10) {
        direction = -1;
    }
    else {
        direction = 0;
    }
    int dir_change = 0;
    if (direction && (direction + prev_direction == 0)) {
        dir_change = direction;
        prev_direction = direction;
        //PDATA (">>>>>> direction change to %d val %f",dir_change,v);
    }
    
    float slope = (v - VBUF_GET(0)) / VBUFSIZE;
    float linearity = 0;
    int t;
    for (t = -SAMPLE_RATE; t < 0; t++) {
        float x = v + t * slope; // the linear point
        float d = x - VBUF_GET(t);
        linearity += d*d;
    }
    linearity = -sqrt(linearity) / SAMPLE_RATE;
    
    if (seg_age > SAMPLE_RATE / 5) { // minimum segment len
        // BP_LIM is really fickle. Try to find a better criteria.
#define BP_LIM 7.5
#define LIN_LIM -6.75
        if ( (g_bp < BP_LIM && linearity > -3)
            // if (   (g_bp < BP_LIM && linearity > -3.5)
            // if (   (g_bp < BP_LIM && linearity > -3.25)
            || (g_bp >= BP_LIM  && linearity > LIN_LIM) // easier cut if more movement
            || dir_change
            || (seg_age >= VBUFSIZE)
            ) {
            // Correct slope for segment
            int N = seg_age;
            float x_1 = VBUF_GET(-N); // Should always be close to zero
            float x_N = VBUF_GET(-1);
            float delta = x_N - x_1;
            float slop = delta / N;
            // Correct slope
            int mt;
            float max_displ = -100000;
            float min_displ = 100000;
            float max_speed = -100000;
            for (mt=-N; mt < 0; mt++) {
                int t = N + mt;
                float speed = VBUF_GET(mt);
                speed -= t * slop;
                speed -= x_1; // speed, corrected for linear integration error
                if (speed > max_speed) { max_speed = speed; }
                displacement += speed / (SAMPLE_RATE);
                if (displacement > max_displ) { max_displ = displacement;}
                if (displacement < min_displ) { min_displ = displacement;}
            } // for
            displacement = SIGN(displacement) * (max_displ - min_displ);
            // No displacement if previous cut was a timeout
            if (bad_cut) {
                displacement = 0; /* PLOG("bad cut"); */
            }
            //            // Try to convert to centimetres (accelerometer only)
            //            if (displacement < 0) {
            //                displacement *= 0.62;
            //            }
            //            else {
            //                displacement *= 0.49;
            //            }
            // Try to convert to centimetres (fusion)
            displacement *= 0.55;
            if (ABS (displacement) > 10) {
                PDATA("Displacement:%.2f",displacement);
            }
            bad_cut = 0;
            // No displacement if buffer full
            if (seg_age >= VBUFSIZE) { displacement = 0; bad_cut = 1; PDATA("cut timeout");}
            *len = seg_age;
            // Translate buffer such that v = 0
            int i;
            for (i=0; i<VBUFSIZE; i++) {
                vbuf[i] -= v;
            }
            seg_age = 0;
            v = 0;
            //PDATA ("CUT %D",ROUND32(linearity*10));
        } // if (can cut)
        else { // no cut
        }
    } // if (seg_age > ...
    VBUF_PUSH(v);
    seg_age++;
    //if (ABS(displacement) > 20) { PDATA ("DISPL:%D",ROUND32(displacement)); }
    return displacement;
} // lp_displacement()


// Ring buffer for some seconds worth of angles
//-----------------------------------------------
#define ANGLE_BUF_SECS 5
#define ANGLE_BUF_SIZE (SAMPLE_RATE*ANGLE_BUF_SECS)

//---------------------------------
int angle (int action
           ,int n1
           ,int n2
           ,float angle_in
           ,float lrangle_in
           ,float *angle_out)
//---------------------------------
// Entry point for all operations relating to angle buffer.
// In C because it will end up on a microcontroller eventually.
{
    static int angle_buf_pos=0;
    static float angle_buf [ANGLE_BUF_SIZE]; // Angles in prev ANGLE_BUF_SECS seconds
    static float lrangle_buf [ANGLE_BUF_SIZE]; // Left/right angles in prev ANGLE_BUF_SECS seconds
    static float angle_buf_up [ANGLE_BUF_SIZE]; // biggest increase between now and beginning of buffer
    static float angle_buf_down [ANGLE_BUF_SIZE]; // biggest decrease between now and beginning of buffer
    
    // Limit range indexes to make sense
    if (n1 < -ANGLE_BUF_SIZE) {
        n1 = -ANGLE_BUF_SIZE;
    }
    if (n2 < -ANGLE_BUF_SIZE) {
        n2 = -ANGLE_BUF_SIZE;
    }
    if (n1 > 0) {
        n1 %= ANGLE_BUF_SIZE;
    }
    if (n2 > 0) {
        n2 %= ANGLE_BUF_SIZE;
    }
    
    if (angle_out) { *angle_out = 0; }
    //-------------------------
    if (LP_INIT == action) {
        for (int i=0; i < ANGLE_BUF_SIZE; i++) {
            angle_buf[i] = 0;
            angle_buf_up[i] = 0;
            angle_buf_down[i] = 0;
        }
        angle_buf_pos = 0;
    } // LP_INIT
    //-------------------------
    else if (LP_PUSH == action) {
        // Push newest angle
        angle_buf[angle_buf_pos] = angle_in;
        // Push newest lrangle
        lrangle_buf[angle_buf_pos] = lrangle_in;
        int i;
        // Find largest increase and decrease of angle
        float max_incr = -1000;
        float max_decr = 1000;
        ILOOP (ANGLE_BUF_SIZE) {
            float delta = angle_in - angle_buf[i];
            if (delta > max_incr) {
                max_incr = delta;
            }
            if (delta < max_decr) {
                max_decr = delta;
            }
        }
        angle_buf_up[angle_buf_pos] = max_incr;
        angle_buf_down[angle_buf_pos] = max_decr;
        angle_buf_pos++;
        angle_buf_pos %= ANGLE_BUF_SIZE;
    } // LP_PUSH
    // n==0 gives oldest entry, n==1 second oldest, ...
    // n==-1 gives newest entry, n== -2 second newest, ...
    //-------------------------
    else if (LP_GET == action) {
        int idx;
        if (angle_buf_pos + n1 >= 0) {
            idx = angle_buf_pos + n1;
        } else {
            idx = ANGLE_BUF_SIZE + angle_buf_pos + n1;
        }
        idx %= ANGLE_BUF_SIZE;
        *angle_out = angle_buf[idx];
    } // LP_GET
    //-------------------------
    else if (LP_GET_LR == action) {
        int idx;
        if (angle_buf_pos + n1 >= 0) {
            idx = angle_buf_pos + n1;
        } else {
            idx = ANGLE_BUF_SIZE + angle_buf_pos + n1;
        }
        idx %= ANGLE_BUF_SIZE;
        *angle_out = lrangle_buf[idx];
    } // LP_GET_LR
    //-------------------------
    else if (LP_GET_INCREASE == action) {
        int idx;
        if (angle_buf_pos + n1 >= 0) {
            idx = angle_buf_pos + n1;
        } else {
            idx = ANGLE_BUF_SIZE + angle_buf_pos + n1;
        }
        idx %= ANGLE_BUF_SIZE;
        *angle_out = angle_buf_up[idx];
    } // LP_GET_INCREASE
    //-------------------------
    else if (LP_GET_DECREASE == action) {
        int idx;
        if (angle_buf_pos + n1 >= 0) {
            idx = angle_buf_pos + n1;
        } else {
            idx = ANGLE_BUF_SIZE + angle_buf_pos + n1;
        }
        idx %= ANGLE_BUF_SIZE;
        *angle_out = angle_buf_down[idx];
    } // LP_GET_DECREASE
    //-------------------------
    else if (LP_GET_LARGEST_INCREASE == action) {
        // Get the largest increase in angle
        // for i >= n1 and i <= n2
        // Return index of max.
        if (n1 > n2) {
            PDATA("ERROR: n1 > n2 in LP_GET_LARGEST_INCREASE");
            return (0);
        }
        float max_incr = -10000;
        int max_i = 100000;
        for (int i = n1; i <= n2; i++) {
            float incr;
            angle (LP_GET_INCREASE,i,0,0,0,&incr);
            if (incr > max_incr) {
                max_incr = incr;
                max_i = i;
            }
        }
        *angle_out = max_incr;
        return max_i;
    } // LP_GET_LARGEST_INCREASE
    //-------------------------
    else if (LP_GET_LARGEST_ANGLE == action) {
        // Get the largest angle
        // for i >= n1 and i <= n2
        // Return index of max.
        if (n1 > n2) {
            PDATA("ERROR: n1 > n2 in LP_GET_LARGEST_ANGLE");
            return (0);
        }
        float max_angle = -10000;
        int max_i = 100000;
        for (int i = n1; i <= n2; i++) {
            float aangle;
            angle (LP_GET,i,0,0,0,&aangle);
            if (aangle > max_angle) {
                max_angle = aangle;
                max_i = i;
            }
        }
        *angle_out = max_angle;
        return max_i;
    } // LP_GET_LARGEST_ANGLE
    //-------------------------
    else if (LP_GET_SMALLEST_ANGLE == action) {
        // Get the smallest angle
        // for i >= n1 and i <= n2
        // Return index of min.
        if (n1 > n2) {
            PDATA("ERROR: n1 > n2 in LP_GET_SMALLEST_ANGLE");
            return (0);
        }
        float min_angle = 10000;
        int min_i = 100000;
        for (int i = n1; i <= n2; i++) {
            float aangle;
            angle (LP_GET,i,0,0,0,&aangle);
            if (aangle < min_angle) {
                min_angle = aangle;
                min_i = i;
            }
        }
        *angle_out = min_angle;
        return min_i;
    } // LP_GET_SMALLEST_ANGLE
    
    //-------------------------
    else if (LP_GET_LARGEST_DECREASE == action) {
        // Get the largest decrease in angle
        // for i >= n1 and i <= n2
        // Return index of max.
        if (n1 > n2) {
            PDATA("ERROR: n1 > n2 in LP_GET_LARGEST_DECREASE");
            return (0);
        }
        float max_decr = 10000;
        int max_i = 100000;
        for (int i = n1; i <= n2; i++) {
            float decr;
            angle (LP_GET_DECREASE,i,0,0,0,&decr);
            if (decr < max_decr) {
                max_decr = decr;
                max_i = i;
            }
        }
        *angle_out = max_decr;
        return max_i;
    } // LP_GET_LARGEST_DECREASE
    //-------------------------
    else if (LP_GET_ANGLE_CHANGE == action) {
        // Get the difference between the largest and smallest
        // angle since n1.
        float max_angle = -10000;
        float min_angle = 10000;
        for (int i = n1; i < 0; i++) {
            float aangle;
            angle (LP_GET,i,0,0,0,&aangle);
            if (aangle < min_angle) {
                min_angle = aangle;
            }
            if (aangle > max_angle) {
                max_angle = aangle;
            }
        }
        *angle_out = max_angle - min_angle;
        return 1;
    } // LP_GET_ANGLE_CHANGE
    //-------------------------
    else if (LP_GET_LRANGLE_CHANGE == action) {
        // Get the difference between the largest and smallest
        // lrangle since n1.
        float max_angle = -10000;
        float min_angle = 10000;
        for (int i = n1; i < 0; i++) {
            float aangle;
            angle (LP_GET_LR,i,0,0,0,&aangle);
            if (aangle < min_angle) {
                min_angle = aangle;
            }
            if (aangle > max_angle) {
                max_angle = aangle;
            }
        }
        *angle_out = max_angle - min_angle;
        return 1;
    } // LP_GET_LRANGLE_CHANGE
    else {
        PDATA ("ERROR: angle(): unknown action %d", action);
    }
    return 1;
} // angle

//---------------
void angle_test()
//---------------
// Unit test for angle buffer operations
{
    int n_errors = 0;
    // Fill angle buf with triangle 1,2,..,63,62,..,1
    int i;
    ILOOP (125) {
        if (i < 63) {
            angle (LP_PUSH,0,0,i+1,0,NULL);
        } else {
            angle (LP_PUSH,0,0,125-i,0,NULL);
        }
    }
    float max_decr;
    // Biggest decrease between now (-1) and ten ticks
    // in the past (-10) should be -62
    angle (LP_GET_LARGEST_DECREASE,-10,-1,0,0,&max_decr);
    if (max_decr != -62) {
        PDATA ("ERROR: angle_test(): failed decrease test 1");
        n_errors++;
    }
    // Biggest decrease between 0 and 10 should be zero
    angle (LP_GET_LARGEST_DECREASE,0,10,0,0,&max_decr);
    if (max_decr != 0) {
        PDATA ("ERROR: angle_test(): failed decrease test 2");
        n_errors++;
    }
    float max_incr;
    // Biggest increase between now (-1) and ten ticks
    // in the past (-10) should be 10
    angle (LP_GET_LARGEST_INCREASE,-10,-1,0,0,&max_incr);
    if (max_incr != 10) {
        PDATA ("ERROR: angle_test(): failed increase test 1");
        n_errors++;
    }
    // Biggest increase between 0 and 10 should be 11
    angle (LP_GET_LARGEST_INCREASE,0,10,0,0,&max_incr);
    if (max_incr != 11) {
        PDATA ("ERROR: angle_test(): failed increase test 2");
        n_errors++;
    }
    // Test limits out of bounds
    angle (LP_GET_LARGEST_INCREASE,-10000,10000,0,0,&max_incr);
    if (max_incr != 63) {
        PDATA ("ERROR: angle_test(): failed limit bound test");
        n_errors++;
    }
    // Push another element to catch +-1 errors
    angle (LP_PUSH,0,0,0,0,NULL);
    // Biggest increase between 0 and 10 should now be 12
    angle (LP_GET_LARGEST_INCREASE,0,10,0,0,&max_incr);
    if (max_incr != 12) {
        PDATA ("ERROR: angle_test(): failed increase test 3");
        n_errors++;
    }
    // Biggest decrease between now (-1) and ten ticks
    // in the past (-10) should now be -63
    angle (LP_GET_LARGEST_DECREASE,-10,-1,0,0,&max_decr);
    if (max_decr != -63) {
        PDATA ("ERROR: angle_test(): failed decrease test 1");
        n_errors++;
    }
} // angle_test()

// Transpose a matrix
//------------------------------------------------
void transpose (LP_matrix *p_m, LP_matrix *p_res)
//------------------------------------------------
{
    if(p_m == NULL) return;
    
    int r,c;
    RLOOP(3) {
        CLOOP(3) {
            p_res->m[c][r] = p_m->m[r][c];
        }
    }
} // transpose()

// Multiply two 3x3 matrices
//--------------------------------------------------------------
void matmul (LP_matrix *p_m1, LP_matrix *p_m2, LP_matrix *p_res)
//--------------------------------------------------------------
{
    if(p_m1 == NULL || p_m2 == NULL) return;
    
    int r,c;
    LP_matrix m2;
    transpose(p_m2,&m2);
    RLOOP(3) {
        CLOOP(3) {
            float *r1 = p_m1->m[r];
            float *r2 = m2.m[c];
            p_res->m[r][c] = r1[0]*r2[0] + r1[1]*r2[1] + r1[2]*r2[2];
        } // CLOOP
    } // RLOOP
} // matmul()


// Multiply a vector and a matrix (3D)
//---------------------------------------------------------
void matxvec (LP_matrix *p_m, float *p_v, float *p_res)
//---------------------------------------------------------
{
    if(p_m == NULL) return;
    
    int r;
    RLOOP(3) {
        float *row = p_m->m[r];
        p_res[r] = (row[0]*p_v[0] + row[1]*p_v[1] + row[2]*p_v[2]);
    } // RLOOP
} // matxvec()

/*
 Get pelvic angle
 */
//-------------------------------------------
float getFbangle (float x, float y, float z)
//-------------------------------------------
{
    if (y > 1.0 / M_SQRT2) { // sqrt(2)
        return 90 + asin(z) * (180.0 / M_PI);
    }
    else {
        return 90 + SIGN(z)*acos(y) * (180.0 / M_PI);
    }
} // lp_angle()

/*
 Get left/right lean angle
 */
//-------------------------------------------
float getLrangle (float x, float y, float z)
//-------------------------------------------
{
    return -asin(x) * (180.0 / M_PI);
} // lp_lrangle()


// Butterworth bandpass 2 to 5 Hertz
// This assumes a sampling rate of 25
// Used for g_bp
// WARNING: Must be called exactly once per sample.
//---------------------------
float lp_bworth_bandpass_2_5 (float p_y)
//---------------------------
{
#define GAIN_BP 1.094772080e+01
    static float xv[5] = {0,0,0,0,0};
    static float yv[5] = {0,0,0,0,0};
    
    xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
    xv[4] = p_y / GAIN_BP;
    yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
    yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
    + ( -0.3476653948 * yv[0] ) + (  1.1502006801 * yv[1] )
    + ( -2.0775438747 * yv[2] ) + (  2.0446387154 * yv[3] );
    return yv[4];
} // lp_bworth_bandpass_2_5()

// Butterworth lowpass 0.5 Hz
// This assumes a sampling rate of 25
// Used for g_bp
// WARNING: Must be called exactly once per sample.
//---------------------------
float lp_bworth_lowpass_05 (float p_y)
//---------------------------
{
#define GAIN_LP 2.761148367e+02
    static float xv[3] = {0,0,0};
    static float yv[3] = {0,0,0};
    xv[0] = xv[1]; xv[1] = xv[2];
    xv[2] = p_y / GAIN_LP;
    yv[0] = yv[1]; yv[1] = yv[2];
    yv[2] =   (xv[0] + xv[2]) + 2 * xv[1]
    + ( -0.8371816513 * yv[0] ) + (  1.8226949252 * yv[1] );
    return yv[2];
} // lp_bworth_lowpass_05()



