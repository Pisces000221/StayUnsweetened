require 'Cocos2d'
require 'src/global'
require 'src/widgets/BackgroundRepeater'

MYTEST2 = {}
MYTEST2.groundYOffset = 80
MYTEST2.backToStartDur = 1.2
MYTEST2.ballFadeOutDur = 0.5
MYTEST2.parallaxBGRate = {}
MYTEST2.parallaxBGRate[1] = 0.6
MYTEST2.parallaxBGRate[2] = 0.35
MYTEST2.BGExtraWidth = 800
MYTEST2.titleYPadding = 24
MYTEST2.titleFadeDur = 0.9

function MYTEST2.create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    
    local titleSprite = globalSprite('game_title')
    titleSprite:setAnchorPoint(cc.p(0.5, 1))
    titleSprite:setPosition(cc.p(size.width / 2, size.height - MYTEST2.titleYPadding))
    --titleSprite:setVisible(false)
    titleSprite:setOpacity(0)
    scene:addChild(titleSprite)
    local scroll = MScrollView:create()
    scroll:horizonalMode()
    scroll:setContentSize(cc.size(AMPERE.MAPSIZE, size.height))
    scroll:setPosition(cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, MYTEST2.groundYOffset))
    scene:addChild(scroll)
    local ground_bg = BackgroundRepeater:create(AMPERE.MAPSIZE + MYTEST2.BGExtraWidth * 2, 'ground')
    ground_bg:setPositionX(-MYTEST2.BGExtraWidth)
    local parallax_bg = cc.ParallaxNode:create()
    parallax_bg:setPosition(cc.p(0, MYTEST2.groundYOffset))
    parallax_bg:setPositionX(-MYTEST2.BGExtraWidth)
    for i = 1, #MYTEST2.parallaxBGRate do
        parallax_bg:addChild(BackgroundRepeater:create(
            AMPERE.MAPSIZE + MYTEST2.BGExtraWidth * 2, 'parallax_bg_' .. i, cc.p(0, 0)),
            i, cc.p(MYTEST2.parallaxBGRate[i], 0.5), cc.p(0, 0))
    end
    scroll:addChild(parallax_bg)
    scroll:addChild(ground_bg)
    
    -- create the crystal ball
    local crystalBallActive = globalSprite('crystal_ball_active')
    local crystalBallIdle = globalSprite('crystal_ball_idle')
    crystalBallActive:setAnchorPoint(cc.p(0.5, 0))
    crystalBallActive:setPosition(cc.p(AMPERE.MAPSIZE / 2, 0))
    crystalBallIdle:setAnchorPoint(cc.p(0.5, 0))
    crystalBallIdle:setPosition(cc.p(AMPERE.MAPSIZE / 2, 0))
    crystalBallIdle:setOpacity(0)
    -- avtive covers idle, just fade active out to set the ball to idle status
    scroll:addChild(crystalBallIdle)
    scroll:addChild(crystalBallActive)
    
    -- create the menu
    local back_item = cc.MenuItemLabel:create(
        cc.Label:createWithTTF(globalTTFConfig(30), 'GO BACK'))
    local start_item_selSprite = globalSprite('crystal_ball_idle')
    start_item_selSprite:setColor(cc.c3b(128, 128, 128))    -- darker
    local start_item = cc.MenuItemSprite:create(
        globalSprite('crystal_ball_idle'), start_item_selSprite)
    
    local idleCrystalBall = function()
        crystalBallIdle:runAction(cc.FadeIn:create(0))
        crystalBallActive:runAction(cc.FadeOut:create(MYTEST2.ballFadeOutDur))
    end
    local hideBackShowStart = function()
        back_item:setVisible(false)
        start_item:setVisible(true)
        titleSprite:runAction(cc.Spawn:create(
            cc.MoveBy:create(MYTEST2.titleFadeDur, cc.p(0, -MYTEST2.titleYPadding)),
            cc.FadeIn:create(MYTEST2.titleFadeDur)))
    end
    local hideStartShowBack = function()
        back_item:setVisible(true)
        start_item:setVisible(false)
        titleSprite:runAction(cc.Spawn:create(
            cc.MoveBy:create(MYTEST2.titleFadeDur, cc.p(0, MYTEST2.titleYPadding)),
            cc.FadeOut:create(MYTEST2.titleFadeDur)))
    end
    local activateCrystalBall = function()
        crystalBallActive:runAction(cc.FadeIn:create(MYTEST2.ballFadeOutDur))
        start_item:setVisible(false)
        crystalBallIdle:runAction(cc.Sequence:create(
            cc.DelayTime:create(MYTEST2.ballFadeOutDur),
            cc.FadeOut:create(0)))
    end
    local backCallback = function()
        scroll:stopRefreshing()
        scroll:disableTouching()
        scroll:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.MoveTo:create(
                MYTEST2.backToStartDur,
                cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, MYTEST2.groundYOffset))),
            cc.CallFunc:create(idleCrystalBall),
            cc.DelayTime:create(MYTEST2.ballFadeOutDur),
            cc.CallFunc:create(hideBackShowStart)))
    end
    local startCallback = function()
        scroll:enableTouching()
        scroll:runAction(cc.Sequence:create(
            cc.CallFunc:create(activateCrystalBall),
            cc.DelayTime:create(MYTEST2.ballFadeOutDur),
            cc.CallFunc:create(hideStartShowBack)))
    end
    -- CocosDenshionTest.lua (111)
    back_item:registerScriptTapHandler(backCallback)
    back_item:setPosition(cc.p(200, 200))
    start_item:registerScriptTapHandler(startCallback)
    start_item:setAnchorPoint(cc.p(0.5, 0))
    start_item:setPosition(cc.p(size.width / 2, MYTEST2.groundYOffset))
    start_item:setVisible(false)
    local menu = cc.Menu:create(back_item, start_item)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu)
    
    -- call 'back' callback initially
    --backCallback()
    
    return scene
end
