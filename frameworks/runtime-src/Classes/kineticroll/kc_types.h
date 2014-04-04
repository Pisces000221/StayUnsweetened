#ifndef __KINETICROLL_TYPES_H__
#define __KINETICROLL_TYPES_H__

typedef void (*kc_callback_0)(void*);
typedef void (*kc_callback_1)(void*, float);
typedef void (*kc_callback_2)(void*, float, float);

typedef enum __kc_motionstate {
    STOPPED = 0,
    FREE_SCROLL,
    RELEASED_OUTSIDE,
    HIT_BORDER_AWAY,
    HIT_BORDER_BEYOND,
    HIT_BORDER_BACK_ACC,
    HIT_BORDER_BACK_DEC,
    NUM_MOTIONSTATE,    /* the count of the states */
    MS_UNKNOWN = 12138  /* WTF??? */
} kc_motionstate;

typedef enum __kc_bordertype {
    BORDER_NONE = 0,
    BORDER_DOWN_LEFT = 1,
    BORDER_UP_RIGHT = 2,
    BORDER_UNKNOWN = 147106
} kc_bordertype;

typedef struct __kc_scrollstate {
    kc_motionstate motion;
    kc_bordertype border;
    kc_bordertype velocity;
} kc_scrollstate;

#endif
