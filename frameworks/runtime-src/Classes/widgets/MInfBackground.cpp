#include "MInfBackground.h"
#include <string>

#include "cocos2d.h"
using namespace cocos2d;

namespace M {

float myModF(float a, float b)
{
    if (a > 0) {
        while (a > 0) a -= b;
    } else {
        while (a < 0) a += b;
        if (a > 0) a -= b;
    }
    return a;
}

// ******** creation and initialization interfaces ********
InfBackground* InfBackground::create(const std::string &filename)
{
    InfBackground *ib = new InfBackground();
    if (ib && ib->initWithFile(filename)) {
        ib->autorelease();
        return ib;
    }
    CC_SAFE_DELETE(ib);
    return nullptr;
}

InfBackground* InfBackground::createWithSpriteFrame(const std::string &frameName)
{
    InfBackground *ib = new InfBackground();
    if (ib && ib->initWithSpriteFrame(frameName)) {
        ib->autorelease();
        return ib;
    }
    CC_SAFE_DELETE(ib);
    return nullptr;
}

InfBackground* InfBackground::create()
{
    return InfBackground::create("");
}

bool InfBackground::initWithFile(const std::string &filename)
{
    if (!Layer::init()) return false;
    _filename = filename;
    _batch = SpriteBatchNode::create(filename);
    this->addChild(_batch);
    // get width of the image set
    auto image = new Image();
    image->initWithImageFile(filename);
    _spriteWidth = image->getWidth();
    this->updateSprites();
    return true;
}

bool InfBackground::initWithSpriteFrame(const std::string &frameName)
{
    if (!Layer::init()) return false;
    _isUsingFrame = true;
    _filename = frameName;
    Rect r = SpriteFrameCache::getInstance()
        ->getSpriteFrameByName(frameName)->getRect();
    _spriteWidth = r.getMaxX() - r.getMinX();
    this->updateSprites();
    return true;
}

bool InfBackground::init()
{
    return initWithFile("");
}
// ******** ********

void InfBackground::setPosition(const Point &pos)
{
    Layer::setPosition(pos);
    updateSprites();
}

void InfBackground::updateSprites()
{
    if (!_isUsingFrame) _batch->removeAllChildrenWithCleanup(true);
    // We just get the X value of the position
    // If you want to use the vertical version of this, make it for yourself :)
    //www.cocos2d-x.org/forums/6/topics/9192
    float p = _position.x;
    float vw = Director::getInstance()->getVisibleSize().width;
    float dp = myModF(p, _spriteWidth);
    while (dp <= vw) {
        auto sprite = _isUsingFrame ?
            Sprite::createWithSpriteFrame(
                SpriteFrameCache::getInstance()->getSpriteFrameByName(_filename))
            : Sprite::create(_filename);
        sprite->setAnchorPoint(Point::ANCHOR_BOTTOM_LEFT);
        sprite->setPosition(Point(dp - p, 0));
        if (_isUsingFrame) this->addChild(sprite);
        else _batch->addChild(sprite);
        dp += _spriteWidth;
    }
}

}
