#include "MoveRotate90.h"
#include <math.h>
using namespace M;

namespace M {

MoveRotate90* MoveRotate90::create(float duration, const Point& origin, bool isClockwise)
{
    MoveRotate90 *ret = new MoveRotate90();
    ret->initWithDuration(duration, origin, isClockwise);
    ret->autorelease();

    return ret;
}
MoveRotate90* MoveRotate90::create(float duration, const Point& origin)
{ return MoveRotate90::create(duration, origin, true); }

bool MoveRotate90::initWithDuration(float duration, const Point& origin, bool isClockwise)
{
    if (ActionInterval::initWithDuration(duration)) {
        _origin = origin;
        _isClockwise = isClockwise;
        return true;
    }

    return false;
}

MoveRotate90* MoveRotate90::clone(void) const
{
	auto a = new MoveRotate90();
    a->initWithDuration(_duration, _origin, _isClockwise);
	a->autorelease();
	return a;
}

void MoveRotate90::startWithTarget(Node *target)
{
    ActionInterval::startWithTarget(target);
    _startPosition = target->getPosition();
    Point deltaP = _startPosition - _origin;
    _startAngle = atan2f(deltaP.y, deltaP.x);
}

// WARNING: This can not be used yet.
// Anybody improves this?
MoveRotate90* MoveRotate90::reverse() const
{
    auto ret = MoveRotate90::create(_duration, _origin, !_isClockwise);
    if (ret) return ret;
    else return nullptr;
}

void MoveRotate90::update(float rate)
{
    if (_target) {
        Point pos = _startPosition;
        pos = pos.rotateByAngle(_origin,
            _isClockwise ? -M_PI * 0.5 * rate : M_PI * 0.5 * rate);
        _target->setPosition(pos);
    }
}

}
