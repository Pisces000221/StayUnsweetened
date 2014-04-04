#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "tolua/tolua_all.h"

using namespace cocos2d;
using namespace CocosDenshion;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director & window (or GL view, whatever.)
    auto director = Director::getInstance();
	auto glview = director->getOpenGLView();
	if (!glview) {
		glview = GLView::createWithRect("Stay Unsweetened", Rect(0, 0, 960, 640));
		director->setOpenGLView(glview);
	}
    glview->setDesignResolutionSize(960, 640, ResolutionPolicy::SHOW_ALL);
    director->setDisplayStats(true);
    director->setAnimationInterval(1.0 / 60);

	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
    CCLOG("Binding classes to Lua...");
    tolua_bindAllManual(engine->getLuaStack()->getLuaState());
	engine->executeScriptFile("src/rock.lua");

    return true;
}

void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
