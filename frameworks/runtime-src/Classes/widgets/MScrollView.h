#ifndef __AMPERE_WIDGET_SCROLL_VIEW_H__
#define __AMPERE_WIDGET_SCROLL_VIEW_H__

#include <sys/timeb.h>
extern "C" {
#include "../kineticroll/kc_linearscroll.h"
}

#include "cocos2d.h"
using namespace cocos2d;

namespace M {

class ScrollView : public cocos2d::Layer
{
public:
    ScrollView() : _is_horizonal(false), _is_refreshing(false) {}
    ~ScrollView() {}
    bool init();
    CREATE_FUNC(ScrollView);

    virtual void setContentSize(Size s);
    void updateSizes();
    void verticalMode() { _is_horizonal = false; updateSizes(); }
    void horizonalMode() { _is_horizonal = true; updateSizes(); }
    bool isHorizonal() { return _is_horizonal; }

    inline void startRefreshing()
    { _is_refreshing = true; Director::getInstance()->getScheduler()->scheduleSelector(refresh_selector, this, 0, false); }
    inline void stopRefreshing()
    { _is_refreshing = false; Director::getInstance()->getScheduler()->unscheduleSelector(refresh_selector, this); }
    inline bool isRefreshing()
    { return _is_refreshing; }
protected:
    void refresh(float dt);
    SEL_SCHEDULE refresh_selector;
    bool _is_horizonal;
    bool _is_refreshing;

    kc_linearscroll *_kineti;
};

inline void ScrollView_updatePos(void *arg, float p)
{
    ScrollView *t = (ScrollView *)arg;
    if (t->isHorizonal()) t->setPositionX(p);
    else t->setPositionY(p);
}

inline void ScrollView_startRefreshing(void *arg)
{ ((ScrollView *)arg)->startRefreshing(); }

inline void ScrollView_stopRefreshing(void *arg)
{ ((ScrollView *)arg)->stopRefreshing(); }

}

#endif
