#include "MInfBackground.h"
#include <string>

#include "cocos2d.h"
using namespace cocos2d;

namespace M {

float myModF(float a, float b)
{
    if (a > 0) {
        while (a > 0) a -= b;
        //if (a < 0) a += b;
        //a -= b;
        //a = -myModF(-a, b);
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
    //auto texture = new Texture2D();
    //texture->initWithImage(image);
    _spriteWidth = image->getWidth();
    CCLOG("_spriteWidth = %f", _spriteWidth);
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
    _batch->removeAllChildrenWithCleanup(true);
    // We just get the X value of the position
    // If you want to use the vertical version of this, make it for yourself :)
    //www.cocos2d-x.org/forums/6/topics/9192
    float p = _position.x;
    float vw = Director::getInstance()->getVisibleSize().width;
    float dp = myModF(p, _spriteWidth);
    //int ct = 0;
    //CCLOG("p = %f, dp = %f", p, dp);
    while (dp <= vw) {
        auto sprite = Sprite::create(_filename);
        sprite->setAnchorPoint(Point::ANCHOR_BOTTOM_LEFT);
        sprite->setPosition(Point(dp - p, 0));
        _batch->addChild(sprite);
        dp += _spriteWidth;
        //ct++;
    }
    //CCLOG("ct = %d", ct);
}

}
