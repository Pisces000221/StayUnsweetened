#include "MScrollView.h"
#include <math.h>
#include <sys/timeb.h>

#include "cocos2d.h"
using namespace cocos2d;

#define SCROLL_POSITION(p) (_is_horizonal ? p.x : p.y)

namespace M {

void ScrollView::updateSizes()
{
    // Update the kinetiCroll context with the new content size
    if (_is_horizonal) {
        kc_setvisiblesize(_kineti, Director::getInstance()->getVisibleSize().width);
        kc_setcontentsize(_kineti, this->getContentSize().width);
    } else {
        kc_setvisiblesize(_kineti, Director::getInstance()->getVisibleSize().height);
        kc_setcontentsize(_kineti, this->getContentSize().height);
    }
    // ... and the new position
    kc_setmypos(_kineti, SCROLL_POSITION(_position));
}

bool ScrollView::init()
{
    if (!Layer::init()) return false;
    
    // Initialise the kinetiCroll context
    _kineti = kc_init();
    kc_setuserdata(_kineti, this);
    kc_setcallback_0(_kineti, START_REFRESHING, &ScrollView_startRefreshing);
    kc_setcallback_0(_kineti, STOP_REFRESHING, &ScrollView_stopRefreshing);
    kc_setcallback_1(_kineti, UPDATE_POSITION, &ScrollView_updatePos);
    this->updateSizes();

    // create the selector used by startRefreshing, etc.
    refresh_selector = schedule_selector(ScrollView::refresh);

    // enable touching
    _listener = EventListenerTouchOneByOne::create();
    _listener->setSwallowTouches(true);

    // Let's get something HIGH-LEVEL, GENEROUS[?], and FIRST-LEVEL
    // Maybe it's better to call it ADVANCED.
    _listener->onTouchBegan = [=](Touch *touch, Event *event) {
        this->updateSizes();
        Point pos = touch->getLocation();
        kc_activate(_kineti, TOUCH_BEGAN, SCROLL_POSITION(pos));
        return true;
    };

    _listener->onTouchMoved = [=](Touch *touch, Event *event) {
        Point pos = touch->getLocation();
        kc_activate(_kineti, TOUCH_MOVED, SCROLL_POSITION(pos));
    };

    _listener->onTouchEnded = [=](Touch *touch, Event *event) {
        Point pos = touch->getLocation();
        kc_activate(_kineti, TOUCH_ENDED, SCROLL_POSITION(pos));
    };

    _eventDispatcher->addEventListenerWithSceneGraphPriority(_listener, this);
    return true;
}

// updates inertia scrolling
void ScrollView::refresh(float dt)
{
    kc_activate(_kineti, REFRESH_TICK, dt);
}

}
