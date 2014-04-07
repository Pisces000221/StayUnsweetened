require 'Cocos2d'
require 'src/global'
require 'src/widgets/BackgroundRepeater'
require 'src/widgets/SimpleMenuItemSprite'

StartupScene = {}
StartupScene.groundYOffset = 80
StartupScene.backToStartDur = 1.2
StartupScene.ballFadeOutDur = 0.5
StartupScene.parallaxBGRate = {}
StartupScene.parallaxBGRate[1] = 0.6
StartupScene.parallaxBGRate[2] = 0.35
StartupScene.BGExtraWidth = 800
StartupScene.titleYPadding = 24
StartupScene.titleFadeDur = 0.9
StartupScene.iconMenuPadding = 10
StartupScene.iconMenuGetInDur = 1.5
StartupScene.iconMenuGetOutDur = 0.6
StartupScene.iconMenuActionIntv = 0.2

function StartupScene.create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    
    local titleSprite = globalSprite('game_title')
    titleSprite:setAnchorPoint(cc.p(0.5, 1))
    titleSprite:setPosition(cc.p(size.width / 2, size.height))
    titleSprite:setOpacity(0)
    scene:addChild(titleSprite)
    local scroll = MScrollView:create()
    scroll:horizonalMode()
    scroll:setContentSize(cc.size(AMPERE.MAPSIZE, size.height))
    scroll:setPosition(cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, StartupScene.groundYOffset))
    scene:addChild(scroll)
    local ground_bg = BackgroundRepeater:create(AMPERE.MAPSIZE + StartupScene.BGExtraWidth * 2, 'ground')
    ground_bg:setPositionX(-StartupScene.BGExtraWidth)
    local parallax_bg = cc.ParallaxNode:create()
    parallax_bg:setPosition(cc.p(0, StartupScene.groundYOffset))
    parallax_bg:setPositionX(-StartupScene.BGExtraWidth)
    for i = 1, #StartupScene.parallaxBGRate do
        parallax_bg:addChild(BackgroundRepeater:create(
            AMPERE.MAPSIZE + StartupScene.BGExtraWidth * 2, 'parallax_bg_' .. i, cc.p(0, 0)),
            i, cc.p(StartupScene.parallaxBGRate[i], 0.5), cc.p(0, 0))
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
    local back_item, start_item, options_item, about_item
    
    local idleCrystalBall = function()
        crystalBallIdle:setOpacity(255)
        crystalBallActive:runAction(cc.FadeOut:create(StartupScene.ballFadeOutDur))
    end
    local hideBackShowStart = function()
        back_item:setVisible(false)
        start_item:setVisible(true)
        titleSprite:runAction(cc.Spawn:create(
            cc.MoveBy:create(StartupScene.titleFadeDur, cc.p(0, -StartupScene.titleYPadding)),
            cc.FadeIn:create(StartupScene.titleFadeDur)))
        local menuAction = cc.EaseElasticOut:create(
            cc.MoveBy:create(StartupScene.iconMenuGetInDur,
            cc.p(0, options_item:getContentSize().height)), 0.8)
        options_item:runAction(menuAction)
        about_item:runAction(cc.Sequence:create(
            cc.DelayTime:create(StartupScene.iconMenuActionIntv),
            menuAction:clone()))
    end
    local hideStartShowBack = function()
        back_item:setVisible(true)
        start_item:setVisible(false)
        titleSprite:runAction(cc.Spawn:create(
            cc.MoveBy:create(StartupScene.titleFadeDur, cc.p(0, StartupScene.titleYPadding)),
            cc.FadeOut:create(StartupScene.titleFadeDur)))
        local menuAction = cc.EaseElasticIn:create(
            cc.MoveBy:create(StartupScene.iconMenuGetOutDur,
            cc.p(0, -options_item:getContentSize().height)), 0.8)
        options_item:runAction(menuAction)
        about_item:runAction(cc.Sequence:create(
            cc.DelayTime:create(StartupScene.iconMenuActionIntv),
            menuAction:clone()))
    end
    local activateCrystalBall = function()
        crystalBallActive:runAction(cc.FadeIn:create(StartupScene.ballFadeOutDur))
        start_item:setVisible(false)
        crystalBallIdle:runAction(cc.Sequence:create(
            cc.DelayTime:create(StartupScene.ballFadeOutDur),
            cc.FadeOut:create(0)))
    end
    local backCallback = function()
        scroll:stopRefreshing()
        scroll:disableTouching()
        scroll:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.MoveTo:create(
                StartupScene.backToStartDur,
                cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, StartupScene.groundYOffset))),
            cc.CallFunc:create(idleCrystalBall),
            cc.DelayTime:create(StartupScene.ballFadeOutDur),
            cc.CallFunc:create(hideBackShowStart)))
    end
    local startCallback = function()
        scroll:enableTouching()
        scroll:runAction(cc.Sequence:create(
            cc.CallFunc:create(activateCrystalBall),
            cc.DelayTime:create(StartupScene.ballFadeOutDur),
            cc.CallFunc:create(hideStartShowBack)))
    end
    back_item = cc.MenuItemLabel:create(
        cc.Label:createWithTTF(globalTTFConfig(30), 'GO BACK'))
    back_item:registerScriptTapHandler(backCallback)
    back_item:setPosition(cc.p(200, 200))
    start_item = SimpleMenuItemSprite:create('crystal_ball_idle', startCallback)
    start_item:setAnchorPoint(cc.p(0.5, 0))
    start_item:setPosition(cc.p(size.width / 2, StartupScene.groundYOffset))
    start_item:setVisible(false)
    
    options_item = SimpleMenuItemSprite:create('options', function() end)
    options_item:setAnchorPoint(cc.p(0, 0))
    options_item:setPosition(cc.p(0, -options_item:getContentSize().height))
    about_item = SimpleMenuItemSprite:create('about', function() end)
    about_item:setAnchorPoint(cc.p(0, 0))
    about_item:setPosition(cc.p(globalImageWidth('options') + StartupScene.iconMenuPadding, -about_item:getContentSize().height))
    local menu = cc.Menu:create(back_item, start_item, options_item, about_item)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu)
    
    crystalBallActive:setOpacity(0)
    crystalBallIdle:setOpacity(255)
    hideBackShowStart()
    -- Let's go Lisp :)
    scroll:runAction(cc.Sequence:create(
        cc.DelayTime:create(0),     -- wait for one frame
        cc.CallFunc:create(function() scroll:disableTouching() end)))
    
    return scene
end
