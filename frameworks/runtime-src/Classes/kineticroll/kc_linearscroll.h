#ifndef __KINETICROLL_LINEAR_SCROLL_H__
#define __KINETICROLL_LINEAR_SCROLL_H__

#include <sys/timeb.h>
#include "kc_types.h"

#define TOUCHES_RECORDED 20
typedef struct __kc_linearscroll {
    float _visiblesize;
    float _contentsize;
    float _rate;
    kc_callback_0 call0[10];
    kc_callback_1 call1[10];
    kc_callback_2 call2[10];

    kc_scrollstate _state;
    int _refreshing;
    float _curpos;
    float _v;
    struct timeb _ttime[TOUCHES_RECORDED];
    float _tpos[TOUCHES_RECORDED];
    float _tn[NUM_MOTIONSTATE]; /* stores the time to stop, etc. */
    float _dn[NUM_MOTIONSTATE]; /* stores the distance at some time. */
    float _vn[NUM_MOTIONSTATE]; /* stores the velocity at some time. */
    /* PS. _tn means the duration,
     *     _vn means the linear velocity when stopped,
     * and _dn means the position when started. */
    
    void *_userdata;
} kc_linearscroll;

/* callback indexes with 0 arguments */
#define START_REFRESHING 0
#define STOP_REFRESHING 1
/* callback indexes with 1 arguments */
#define UPDATE_POSITION 0
/* event indexes */
#define TOUCH_BEGAN 0
#define TOUCH_MOVED 1
#define TOUCH_ENDED 2
#define REFRESH_TICK 3

/* time (stored in _tn) indexes */
/* The same as those in enum __kc_motionstate, except... */
#define TN_TOTAL 0

/* Resurns an initialised context. */
extern kc_linearscroll *kc_init();
/* Sets visible & content sizes for a context. */
extern void kc_setvisiblesize(kc_linearscroll*, float);
extern void kc_setcontentsize(kc_linearscroll*, float);
/* Sets user data for a conext. */
extern void kc_setuserdata(kc_linearscroll*, void*);
/* Sets callbacks for a context. */
extern void kc_setcallback_0(kc_linearscroll*, int, kc_callback_0);
extern void kc_setcallback_1(kc_linearscroll*, int, kc_callback_1);
extern void kc_setcallback_2(kc_linearscroll*, int, kc_callback_2);
/* Activates events for a context. */
extern int kc_activate(kc_linearscroll*, int, float);

/* Initialises touch data for a context. */
extern void kc_inittouchdata(kc_linearscroll*, float);
/* Starts or stops refreshing for a context. */
extern void kc_startrefresh(kc_linearscroll*);
extern void kc_stoprefresh(kc_linearscroll*);
/* Sets a custom position. */
extern void kc_setmypos(kc_linearscroll*, float);
extern float kc_getmypos(kc_linearscroll*);
/* Sets a normal position. Only used when out-of-border. */
extern void kc_setpos(kc_linearscroll*, float);
extern float kc_getpos(kc_linearscroll*);

#endif
