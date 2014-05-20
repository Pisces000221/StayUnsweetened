#ifndef __UPDATER_UPDATESCENE_H__
#define __UPDATER_UPDATESCENE_H__

#include "updater.h"
#include "cocos2d.h"

class UpdateScene : public cocos2d::LayerColor
{
public:
    UpdateScene() {}
    ~UpdateScene() {}
    bool init();
    CREATE_FUNC(UpdateScene);
    static cocos2d::Scene *scene()
    {
        cocos2d::Scene *s = cocos2d::Scene::create();
        UpdateScene *u = UpdateScene::create();
        s->addChild(u);
        return s;
    }
protected:
    void checkUpdate();
};

#endif
