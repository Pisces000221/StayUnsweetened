#ifndef __AMPERE_WIDGET_INF_BACKGROUND_H__
#define __AMPERE_WIDGET_INF_BACKGROUND_H__

#include <string>

#include "cocos2d.h"
using namespace cocos2d;

namespace M {

class InfBackground : public cocos2d::Layer
{
public:
    InfBackground() : _isUsingFrame(false) {}
    ~InfBackground() {}
    bool initWithFile(const std::string &filename);
    bool initWithSpriteFrame(const std::string &frameName);
    bool init();
    static InfBackground* create();
    static InfBackground* create(const std::string &filename);
    static InfBackground* createWithSpriteFrame(const std::string &frameName);

    virtual void setPosition(const Point &pos);
    void updateSprites();
protected:
    bool _isUsingFrame;
    std::string _filename;
    SpriteBatchNode *_batch;
    float _spriteWidth;
};

}

#endif
