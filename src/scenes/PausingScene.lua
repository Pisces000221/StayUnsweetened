require 'Cocos2d'
require 'src/global'

PausingScene = {}
PausingScene.iconFadeDur = 0.2
PausingScene.iconOpacity = 128
PausingScene.iconTintDur = 1.5
PausingScene.iconTintWhite = 192
PausingScene.backgroundTintDur = 0.2
PausingScene.backgroundTintWhite = 128
PausingScene.tapMaxDur = 0.7

function PausingScene.create(self, anchor, pos)
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()

    -- display background
    --www.cocos2d-x.org/wiki/How_to_Save_a_Screenshot
    local texture = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    texture:beginWithClear(0, 0, 0, 0)
    cc.Director:getInstance():getRunningScene():visit()
    texture:endToLua()
    local bgSprite = texture:getSprite()
    bgSprite:removeFromParent()
    bgSprite:setAnchorPoint(cc.p(0, 0))
    bgSprite:setPosition(cc.p(0, 0))
    bgSprite:setScale(0.99999)
    bgSprite:setFlippedY(true)
    scene:addChild(texture:getSprite())
    bgSprite:runAction(cc.TintTo:create(
        PausingScene.backgroundTintDur, PausingScene.backgroundTintWhite,
        PausingScene.backgroundTintWhite, PausingScene.backgroundTintWhite))

    local icon = globalSprite('pause')
    icon:setAnchorPoint(anchor)
    icon:setPosition(pos)
    scene:addChild(icon)
    icon:setColor(cc.c3b(PausingScene.iconTintWhite, PausingScene.iconTintWhite, PausingScene.iconTintWhite))
    icon:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.TintTo:create(PausingScene.iconTintDur, 255, 255, 255),
        cc.TintTo:create(PausingScene.iconTintDur, PausingScene.iconTintWhite,
            PausingScene.iconTintWhite, PausingScene.iconTintWhite)
    )))
    
    -- hello.lua (132)
    -- handing touch events
    local lastTouchBegan = 0
    local function onTouchBegan(touch, event)
        lastTouchBegan = os.time()
        return true
    end
    local function onTouchEnded(touch, event)
        if os.time() - lastTouchBegan <= PausingScene.tapMaxDur then
            bgSprite:runAction(cc.TintTo:create(
                PausingScene.backgroundTintDur, 255, 255, 255))
            icon:runAction(cc.EaseSineIn:create(
                cc.FadeTo:create(PausingScene.iconFadeDur, PausingScene.iconOpacity)))
            scene:runAction(cc.Sequence:create(
                cc.DelayTime:create(PausingScene.backgroundTintDur),
                cc.CallFunc:create(function()
                    cc.Director:getInstance():popScene() end)))
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)

    return scene
end
