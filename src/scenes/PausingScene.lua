require 'Cocos2d'
require 'src/global'
require 'src/widgets/SimpleMenuItemSprite'

PausingScene = {}
PausingScene.iconFadeDur = 0.2
PausingScene.iconOpacity = 128
PausingScene.iconTintDur = 1.5
PausingScene.iconTintWhite = 128
PausingScene.restartMoveDur = 1.4
PausingScene.restartXPadding = 16
PausingScene.backgroundTintDur = 0.2
PausingScene.backgroundTintWhite = 128
PausingScene.tapMaxDur = 0.7

function PausingScene.create(self, anchor, pos, callback)
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    local resume    -- implement later
    
    -- add sandwich to the scene
    local sandwich = cc.Layer:create()
    scene:addChild(sandwich)

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

    local restartButton = SimpleMenuItemSprite:create('restart',
        function() resume(true) end)
    local restartWidth = globalImageWidth('restart')
    restartButton:setAnchorPoint(anchor)
    restartButton:setPosition(cc.p(
        pos.x + icon:getContentSize().width + PausingScene.restartXPadding, pos.y + restartWidth))
    local resetMenu = cc.Menu:create(restartButton)
    resetMenu:setPosition(cc.p(0, 0))
    scene:addChild(resetMenu)
    restartButton:runAction(cc.EaseElasticOut:create(cc.MoveBy:create(
        PausingScene.restartMoveDur, cc.p(0, -restartWidth)), 0.8))

    -- hello.lua (132)
    -- handing touch events
    local lastTouchBegan = 0
    local function onTouchBegan(touch, event)
        lastTouchBegan = os.time()
        return true
    end
    local function onTouchEnded(touch, event)
        if os.time() - lastTouchBegan <= PausingScene.tapMaxDur then resume(false) end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = sandwich:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, sandwich)
    
    resume = function(choseToRestart)
        bgSprite:runAction(cc.TintTo:create(
            PausingScene.backgroundTintDur, 255, 255, 255))
        icon:runAction(cc.EaseSineIn:create(
            cc.FadeTo:create(PausingScene.iconFadeDur, PausingScene.iconOpacity)))
        restartButton:runAction(cc.MoveBy:create(
            PausingScene.backgroundTintDur, cc.p(0, restartWidth)))
        scene:runAction(cc.Sequence:create(
            cc.DelayTime:create(PausingScene.backgroundTintDur),
            cc.CallFunc:create(function()
                cc.Director:getInstance():popScene() end)))
        callback(choseToRestart)
    end

    return scene
end
