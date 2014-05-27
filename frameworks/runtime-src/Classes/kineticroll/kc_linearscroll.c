#include "kc_linearscroll.h"
/* http://stackoverflow.com/questions/977233/
 * warning-incompatible-implicit-declaration-of-built-in-function-xyz*/
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef TRUE
    #define TRUE 1
#endif
#ifndef FALSE
    #define FALSE 1
#endif

float timeb_diff(struct timeb t1, struct timeb t2)
{ return t1.time - t2.time + (t1.millitm - t2.millitm) / 1000.0; }

int sign(float f) { if (f > 0) return 1; else return f == 0 ? 0 : -1; }
int positive(float f) { return f >= 0 ? 1 : 0; }
/* I wanted to use the ^ operator, but sign() returns 1 or -1, you know, so... */
int diffsign(float a, float b) { return (a > 0 && b < 0) || (a < 0 && b > 0); }
#define square(x) ((x) * (x))
#ifndef max
#define max(a, b) (a > b ? a : b)
#endif
#ifndef min
#define min(a, b) (a < b ? a : b)
#endif

float tottime(float v0, float a, float d)
{ return (abs(v0) - sqrt(max(v0*v0-2.0*a*abs(d), 0))) / a; }
float beyond_dist(float s, float p)
{
    if (p > 0) return p;
    else if (p < -s) return -p - s;
    else return 0;
}

const float REFRESH_INTERVAL = (float)(1 / 60.0);
const float CONST_MIN_VELOCITY = 1000;
const float CONST_TOUCH_MAX_DUR = 0.15;
const float CONST_NORMAL_ACCEL = 1500;
const float CONST_RELEASEOUT_DECEL = 4800;
const float CONST_BOUNCEAWAY_DECEL = 15500;
const float CONST_BOUNCEBACK_DUR = 0.3;
const float CONST_BEYOND_DISTANCE = 150;
const float CONST_BEYOND_DUR = 0.03;

#define REFRESH_INTERVAL (CONST_REFRESH_INTERVAL * context->_rate)
#define MIN_VELOCITY (CONST_MIN_VELOCITY * context->_rate)
#define TOUCH_MAX_DUR (CONST_TOUCH_MAX_DUR * context->_rate)
#define NORMAL_ACCEL (CONST_NORMAL_ACCEL * context->_rate)
#define RELEASEOUT_DECEL (CONST_RELEASEOUT_DECEL * context->_rate)
#define BOUNCEAWAY_DECEL (CONST_BOUNCEAWAY_DECEL * context->_rate)
#define BOUNCEBACK_DUR (CONST_BOUNCEBACK_DUR * context->_rate)
#define BEYOND_DISTANCE (CONST_BEYOND_DISTANCE * context->_rate)
#define BEYOND_DUR (CONST_BEYOND_DUR * context->_rate)

kc_linearscroll *kc_init()
{
    kc_linearscroll *context = (kc_linearscroll *)malloc(sizeof(kc_linearscroll));
    context->_refreshing = 0;
    context->_curpos = context->_v = 0;
    context->_rate = 1;
    context->_state.motion = STOPPED;
    context->_state.border = BORDER_NONE;
    memset(context->_tn, NUM_MOTIONSTATE, sizeof(float));
    memset(context->_dn, NUM_MOTIONSTATE, sizeof(float));
    memset(context->_vn, NUM_MOTIONSTATE, sizeof(float));
    kc_inittouchdata(context, 0);
    return context;
}

void kc_setvisiblesize(kc_linearscroll *context, float new_size)
{
    context->_visiblesize = new_size;
    if (new_size > context->_contentsize) context->_contentsize = new_size;
}
void kc_setcontentsize(kc_linearscroll *context, float new_size)
{
    context->_contentsize = max(new_size, context->_visiblesize);
}
void kc_setuserdata(kc_linearscroll *context, void *data)
{ context->_userdata = data; }

void kc_setcallback_0(kc_linearscroll *context, int index, kc_callback_0 callback)
{ context->call0[index] = callback; }
void kc_setcallback_1(kc_linearscroll *context, int index, kc_callback_1 callback)
{ context->call1[index] = callback; }
void kc_setcallback_2(kc_linearscroll *context, int index, kc_callback_2 callback)
{ context->call2[index] = callback; }

void kc_setpos(kc_linearscroll *context, float pos)
{ context->_curpos = pos; (*context->call1[UPDATE_POSITION])(context->_userdata, context->_curpos); }
float kc_getpos(kc_linearscroll *context)
{ return context->_curpos; }

void kc_inittouchdata(kc_linearscroll *context, float pos)
{
	int i;
    struct timeb now;
    ftime(&now);
    for (i = 0; i < TOUCHES_RECORDED; i++) {
        context->_ttime[i] = now;
        context->_tpos[i] = pos;
    }
}

void kc_startrefresh(kc_linearscroll *context)
{
    if (context->_refreshing == 0) {
        (*context->call0[START_REFRESHING])(context->_userdata);
        context->_refreshing = 1;
    }
}
void kc_stoprefresh(kc_linearscroll *context)
{
    if (context->_refreshing == 1) {
        (*context->call0[STOP_REFRESHING])(context->_userdata);
        context->_refreshing = 0;
    }
}

#define K 0.382
#define VS context->_visiblesize
void kc_setmypos(kc_linearscroll *context, float pos)
{
    float s = context->_contentsize - context->_visiblesize;
    if (pos > 0) pos = K*(sqrt(pos/VS+K*K*0.25)-K*0.5) * VS;
    else if (pos < -s) pos = -K*(sqrt(-(pos+s)/VS+K*K*0.25)-K*0.5) * VS - s;
    context->_curpos = pos;
    (*context->call1[UPDATE_POSITION])(context->_userdata, context->_curpos);
}
float kc_getmypos(kc_linearscroll *context)
{
    float s = context->_contentsize - context->_visiblesize;
    float pos = context->_curpos;
    if (pos > 0) pos = (square(pos/(VS*K)+K*0.5)-K*K*0.25) * VS;
    else if (pos < -s) pos = -(square(-(pos+s)/(VS*K)+K*0.5)-K*K*0.25) * VS - s;
    return pos;
}
#undef K
#undef VS

int kc_activate(kc_linearscroll *context, int index, float arg)
{
    float pos = arg;
    int i;
    float s, elapsed;
    switch (index) {
        case TOUCH_BEGAN:
            kc_stoprefresh(context);
            context->_v = 0;
            context->_state.motion = STOPPED;
            memset(context->_tn, NUM_MOTIONSTATE, sizeof(float));
            memset(context->_dn, NUM_MOTIONSTATE, sizeof(float));
            memset(context->_vn, NUM_MOTIONSTATE, sizeof(float));
            kc_inittouchdata(context, pos);
            break;
        case TOUCH_MOVED:
            /* move the whole array left */
            for (i = 0; i < TOUCHES_RECORDED - 1; i++) {
                context->_ttime[i] = context->_ttime[i + 1];
                context->_tpos[i] = context->_tpos[i + 1];
            }
            /* record current touch data */
            ftime(&context->_ttime[TOUCHES_RECORDED - 1]);
            context->_tpos[TOUCHES_RECORDED - 1] = pos;
            /* if the touch changed the direction, re-initialise data */
            if (diffsign(
              context->_tpos[TOUCHES_RECORDED-1] - context->_tpos[TOUCHES_RECORDED-2],
              context->_tpos[TOUCHES_RECORDED-2] - context->_tpos[TOUCHES_RECORDED-3]))
                kc_inittouchdata(context, pos);
            /* update position */
            kc_setmypos(context,
                kc_getmypos(context) + context->_tpos[TOUCHES_RECORDED-1] - context->_tpos[TOUCHES_RECORDED-2]);
            break;
        case TOUCH_ENDED:
            /* get current time and save to the last touch data */
            ftime(&context->_ttime[TOUCHES_RECORDED - 1]);
            /* get the current position */
            s = context->_contentsize - context->_visiblesize;
            /* calculate the last velocity */
            elapsed = timeb_diff(context->_ttime[TOUCHES_RECORDED-1], context->_ttime[0]);
            context->_v = (context->_tpos[TOUCHES_RECORDED-1] - context->_tpos[0]) / elapsed;
            if (context->_curpos > 0) {
                float S = kc_getpos(context);
                context->_state.motion = RELEASED_OUTSIDE;
                context->_state.border = BORDER_DOWN_LEFT;
                context->_v = 0; kc_startrefresh(context);
                /* 1/2*a*t^2 = s
                 * therefore, t = sqrt(2s/a). */
                context->_tn[RELEASED_OUTSIDE] = sqrt((S + S) / RELEASEOUT_DECEL);
                context->_dn[RELEASED_OUTSIDE] = kc_getpos(context);
                context->_vn[RELEASED_OUTSIDE] = context->_tn[RELEASED_OUTSIDE] * RELEASEOUT_DECEL;
            } else if (context->_curpos < -s) {
                float S = -kc_getpos(context) - s;
                context->_state.motion = RELEASED_OUTSIDE;
                context->_state.border = BORDER_UP_RIGHT;
                context->_v = 0; kc_startrefresh(context);
                context->_tn[RELEASED_OUTSIDE] = sqrt((S + S) / RELEASEOUT_DECEL);
                context->_dn[RELEASED_OUTSIDE] = kc_getpos(context);
                context->_vn[RELEASED_OUTSIDE] = context->_tn[RELEASED_OUTSIDE] * RELEASEOUT_DECEL;
            } else if (elapsed && elapsed <= TOUCH_MAX_DUR
              && fabs(context->_v) >= MIN_VELOCITY) {
                float V = abs(context->_v);
                float P = kc_getpos(context);
                float VIP = positive(context->_v);  /* velocity is positive? */
                context->_state.motion = FREE_SCROLL;
                kc_startrefresh(context);
                context->_tn[FREE_SCROLL] =
                    tottime(V, NORMAL_ACCEL, VIP ? -P : -P - s);
                context->_dn[FREE_SCROLL] = P;
                context->_vn[FREE_SCROLL] = V;
                context->_state.velocity = VIP ? BORDER_UP_RIGHT : BORDER_DOWN_LEFT;
                /* Calculate time for decelerating and getting away */
                context->_vn[HIT_BORDER_AWAY] =
                    V - context->_tn[FREE_SCROLL] * NORMAL_ACCEL;
            } else {
                context->_v = 0;
                kc_stoprefresh(context);
            }
            break;
        case REFRESH_TICK:
            context->_tn[TN_TOTAL] += arg;
            if (context->_state.motion == FREE_SCROLL) {
                float t = context->_tn[TN_TOTAL];
				float St = (context->_vn[FREE_SCROLL] - 0.5 * NORMAL_ACCEL * t) * t;
                unsigned goon = FALSE;
                if (context->_tn[TN_TOTAL] >= context->_tn[FREE_SCROLL]) {
                    context->_state.motion = HIT_BORDER_AWAY;
                    t = context->_tn[FREE_SCROLL];
                    context->_tn[TN_TOTAL] -= context->_tn[FREE_SCROLL];
                    context->_tn[HIT_BORDER_AWAY] =
                        abs(context->_vn[HIT_BORDER_AWAY]) <= 1e-4 ? 0 :
                        tottime(context->_vn[HIT_BORDER_AWAY], BOUNCEAWAY_DECEL, BEYOND_DISTANCE);
                    goon = TRUE;
                }
                if (context->_state.velocity == BORDER_DOWN_LEFT)
                    /* Negative initial velocity (v0). */
                    kc_setpos(context, context->_dn[FREE_SCROLL] - St);
                else
                    /* Positive initial velocity (v0). */
                    kc_setpos(context, context->_dn[FREE_SCROLL] + St);
                if (goon) context->_dn[HIT_BORDER_AWAY] = kc_getpos(context);   
            } else if (context->_state.motion == HIT_BORDER_AWAY) {
                float t = context->_tn[TN_TOTAL];
                unsigned goon = FALSE;
                if (context->_tn[TN_TOTAL] >= context->_tn[HIT_BORDER_AWAY]) {
                    context->_state.motion = HIT_BORDER_BEYOND;
                    t = context->_tn[HIT_BORDER_AWAY];
                    context->_tn[TN_TOTAL] -= context->_tn[HIT_BORDER_AWAY];
                    goon = TRUE;
                }
                if (context->_state.velocity == BORDER_DOWN_LEFT)
                    kc_setpos(context, context->_dn[HIT_BORDER_AWAY]
                        - t*(context->_vn[HIT_BORDER_AWAY]
                         - 0.5*BOUNCEAWAY_DECEL*t));
                else
                    kc_setpos(context, context->_dn[HIT_BORDER_AWAY]
                        + t*(context->_vn[HIT_BORDER_AWAY]
                         - 0.5*BOUNCEAWAY_DECEL*t));
                if (goon) {
                    context->_dn[HIT_BORDER_BEYOND] = kc_getpos(context);
                    context->_tn[HIT_BORDER_BEYOND] =
                        context->_dn[HIT_BORDER_BEYOND] >= BEYOND_DISTANCE ?
                        0 : BEYOND_DUR;
                    context->_vn[HIT_BORDER_BEYOND] =
                        context->_vn[HIT_BORDER_AWAY]
                        - context->_tn[HIT_BORDER_AWAY] * BOUNCEAWAY_DECEL;
                }
            } else if (context->_state.motion == HIT_BORDER_BEYOND) {
                float t = context->_tn[TN_TOTAL];
                unsigned goon = FALSE;
                if (context->_tn[TN_TOTAL] >= context->_tn[HIT_BORDER_BEYOND]) {
                    context->_state.motion = HIT_BORDER_BACK_ACC;
                    t = context->_tn[HIT_BORDER_BEYOND];
                    context->_tn[TN_TOTAL] -= context->_tn[HIT_BORDER_BEYOND];
                    goon = TRUE;
                }
                if (context->_state.velocity == BORDER_DOWN_LEFT)
                    kc_setpos(context, context->_dn[HIT_BORDER_BEYOND]
                        - t*context->_vn[HIT_BORDER_BEYOND]
                        * (1 - 0.5 * t / BEYOND_DUR));
                else
                    kc_setpos(context, context->_dn[HIT_BORDER_BEYOND]
                        + t*context->_vn[HIT_BORDER_BEYOND]
                        * (1 - 0.5 * t / BEYOND_DUR));
                if (goon) {
					float bd = beyond_dist(
                        context->_contentsize - context->_visiblesize,
                        context->_dn[HIT_BORDER_BACK_ACC]);
                    context->_dn[HIT_BORDER_BACK_ACC] = kc_getpos(context);
                    context->_tn[HIT_BORDER_BACK_ACC] = /* See below */
                    context->_tn[HIT_BORDER_BACK_DEC] = BOUNCEBACK_DUR;
                    context->_vn[HIT_BORDER_BACK_ACC] = 0;
                    context->_vn[HIT_BORDER_BACK_DEC] = 0.5 * bd / context->_tn[HIT_BORDER_BACK_DEC];
                }
            } else if (context->_state.motion == HIT_BORDER_BACK_ACC) {
                float t = context->_tn[TN_TOTAL];
                unsigned goon = FALSE;
                if (context->_tn[TN_TOTAL] >= context->_tn[HIT_BORDER_BACK_ACC]) {
                    context->_state.motion = HIT_BORDER_BACK_DEC;
                    t = context->_tn[HIT_BORDER_BACK_ACC];
                    context->_tn[TN_TOTAL] -= context->_tn[HIT_BORDER_BACK_ACC];
                    goon = TRUE;
                }
                if (context->_state.velocity == BORDER_DOWN_LEFT)
                    kc_setpos(context, context->_dn[HIT_BORDER_BACK_ACC]
                        + context->_vn[HIT_BORDER_BACK_DEC]
                        / context->_tn[HIT_BORDER_BACK_ACC] * t * t);
                else
                    kc_setpos(context, context->_dn[HIT_BORDER_BACK_ACC]
                        - context->_vn[HIT_BORDER_BACK_DEC]
                        / context->_tn[HIT_BORDER_BACK_ACC] * t * t);
                if (goon)
                    context->_dn[HIT_BORDER_BACK_DEC] = kc_getpos(context);
            } else if (context->_state.motion == HIT_BORDER_BACK_DEC) {
                float t = context->_tn[TN_TOTAL];
                if (context->_tn[TN_TOTAL] >= context->_tn[HIT_BORDER_BACK_DEC]) {
                    /* We stop here. */
                    kc_stoprefresh(context);
                    context->_tn[TN_TOTAL] = 0;
                    context->_state.motion = STOPPED;
                    t = context->_tn[HIT_BORDER_BACK_DEC];
                }
                if (context->_state.velocity == BORDER_DOWN_LEFT)
                    kc_setpos(context, context->_dn[HIT_BORDER_BACK_DEC]
                        + 2 * t * context->_vn[HIT_BORDER_BACK_DEC] *
                        (1 - 0.5 * t / context->_tn[HIT_BORDER_BACK_DEC]));
                else
                    kc_setpos(context, context->_dn[HIT_BORDER_BACK_DEC]
                        - 2 * t * context->_vn[HIT_BORDER_BACK_DEC] *
                        (1 - 0.5 * t / context->_tn[HIT_BORDER_BACK_DEC]));
            } else if (context->_state.motion == RELEASED_OUTSIDE) {
                float t = context->_tn[TN_TOTAL];
				float St = (context->_vn[RELEASED_OUTSIDE] - 0.5 * RELEASEOUT_DECEL * t) * t;
                if (context->_tn[TN_TOTAL] >= context->_tn[RELEASED_OUTSIDE]) {
                    kc_stoprefresh(context);
                    t = context->_tn[RELEASED_OUTSIDE];
                    context->_tn[TN_TOTAL] = 0;
                }
                if (context->_state.border == BORDER_DOWN_LEFT)
                    kc_setpos(context, context->_dn[RELEASED_OUTSIDE] - St);
                else
                    kc_setpos(context, context->_dn[RELEASED_OUTSIDE] + St);
            }
            break;
        default:
            /* Invalid index. Return code 1 */
            return 1;
    }
    return 0;
}
