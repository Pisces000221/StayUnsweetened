require 'Cocos2d'
require 'src/global'

PausingScene = {}
PausingScene.iconScale = 4
PausingScene.iconOpacity = 216
PausingScene.iconScaleDur = 0.2
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
    icon:runAction(cc.EaseSineOut:create(cc.Spawn:create(
        cc.ScaleTo:create(PausingScene.iconScaleDur, PausingScene.iconScale),
        cc.FadeTo:create(PausingScene.iconScaleDur, PausingScene.iconOpacity)
    )))
    
    -- hello.lua (132)
    -- handing touch events
    local lastTouchBegan = 0
    local function onTouchBegan(touch, event)
        lastTouchBegan = os.time()
        return true
    end
    local function onTouchMoved(touch, event)
    end
    local function onTouchEnded(touch, event)
        if os.time() - lastTouchBegan <= PausingScene.tapMaxDur then
            bgSprite:runAction(cc.TintTo:create(
                PausingScene.backgroundTintDur, 255, 255, 255))
            icon:runAction(cc.EaseSineIn:create(cc.Spawn:create(
                cc.ScaleTo:create(PausingScene.iconScaleDur, 1),
                cc.FadeTo:create(PausingScene.iconScaleDur, 255)
            )))
            scene:runAction(cc.Sequence:create(
                cc.DelayTime:create(math.max(PausingScene.backgroundTintDur, PausingScene.iconScaleDur)),
                cc.CallFunc:create(function()
                    cc.Director:getInstance():popScene() end)))
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)

    return scene
end
