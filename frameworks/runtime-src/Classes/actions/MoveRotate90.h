#ifndef __AMPERE_ACTION_MOVE_ROTATE90_H__
#define __AMPERE_ACTION_MOVE_ROTATE90_H__

#include "cocos2d.h"
using namespace cocos2d;

namespace M {

class MoveRotate90 : public ActionInterval
{
public:
    /** creates the action **/
    static MoveRotate90* create(float duration, const Point& origin);
    static MoveRotate90* create(float duration, const Point& origin, bool isClockwise);

    virtual MoveRotate90* clone() const override;
    // PS. reverse() is not stable yet. At least in Lua it is.
    // I don't know why... Maybe someone can solve this some day.
	virtual MoveRotate90* reverse(void) const override;
    virtual void startWithTarget(Node *target) override;
    virtual void update(float time) override;

protected:
    MoveRotate90() : _isClockwise(false) {}
    virtual ~MoveRotate90() {}
    /** initializes the action **/
    bool initWithDuration(float duration, const Point& origin, bool isClockwise);

    Point _origin;
    Point _startPosition;
    bool _isClockwise;
    float _startAngle;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(MoveRotate90);
};

}

#endif
