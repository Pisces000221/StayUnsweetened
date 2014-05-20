#include "UpdateScene.h"
#include "updater.h"
#include <thread>
#include "cocos2d.h"
using namespace cocos2d;

void UpdateScene::checkUpdate()
{
    CCLOG("Checking updates...");
    //http://www.cplusplus.com/reference/string/string/substr/
    std::string p = FileUtils::getInstance()->getWritablePath();
    updater::checkUpdate(p.substr(0, p.length() - 1));
    CCLOG("Update checking finished");
}

bool UpdateScene::init()
{
    if (!LayerColor::initWithColor(Color4B(255, 255, 255, 255))) return false;
    Size size = Director::getInstance()->getVisibleSize();
    auto logo = Sprite::create("res/cocos2dx_portrait.png");
    logo->setAnchorPoint(Point(1, 0));
    logo->setPosition(Point(size.width + 64, 64));
    logo->setOpacity(128);
    this->addChild(logo);
    auto powered = Label::createWithTTF(
        TTFConfig("res/fonts/Signika-Regular.ttf", 66), "Powered by");
    powered->setAnchorPoint(Point(0, 1));
    powered->setPosition(Point(48, size.height * 0.382));
    powered->setColor(Color3B(0, 0, 0));
    this->addChild(powered);
    auto cocos2dx = Label::createWithTTF(
        TTFConfig("res/fonts/Signika-Regular.ttf", 88), "Cocos2d-x");
    cocos2dx->setAnchorPoint(Point(0, 1));
    cocos2dx->setPosition(Point(48, size.height * 0.382 - 96));
    cocos2dx->setColor(Color3B(0, 0, 0));
    this->addChild(cocos2dx);
    auto t = std::thread(&UpdateScene::checkUpdate, this);
    t.detach();
    return true;
}
