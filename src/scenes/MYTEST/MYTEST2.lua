require 'Cocos2d'
require 'src/global'

MYTEST2 = {}
MYTEST2.groundYOffset = 80
MYTEST2.backToStartDur = 1.2
MYTEST2.ballFadeOutDur = 0.5

function MYTEST2.create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    
    local ground_bg = MScrollView:create()
    ground_bg:horizonalMode()
    ground_bg:setContentSize(cc.size(AMPERE.MAPSIZE, size.height))
    local crystalBallActive = globalSprite('crystal_ball_active_1')
    local crystalBallIdle = globalSprite('crystal_ball_idle_1')
    crystalBallActive:setAnchorPoint(cc.p(0.5, 0))
    crystalBallActive:setPosition(cc.p(AMPERE.MAPSIZE / 2, 0))
    ground_bg:addChild(crystalBallActive)
    crystalBallIdle:setAnchorPoint(cc.p(0.5, 0))
    crystalBallIdle:setPosition(cc.p(AMPERE.MAPSIZE / 2, 0))
    crystalBallIdle:setOpacity(0)
    ground_bg:addChild(crystalBallIdle)
    local curp = 0
    while curp < AMPERE.MAPSIZE do
        local sprite = globalSprite('ground_1')
        sprite:setAnchorPoint(cc.p(0, 1))
        sprite:setPosition(cc.p(curp, 0))
        ground_bg:addChild(sprite)
        curp = curp + globalImageWidth('ground_1')
    end
    ground_bg:setPosition(cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, MYTEST2.groundYOffset))
    scene:addChild(ground_bg)
    local back_item = cc.MenuItemLabel:create(
        cc.Label:createWithTTF(globalTTFConfig(30), 'GO BACK'))
    local start_item_selSprite = globalSprite('crystal_ball_idle_1')
    start_item_selSprite:setColor(cc.c3b(128, 128, 128))    -- darker
    local start_item = cc.MenuItemSprite:create(
        globalSprite('crystal_ball_idle_1'), start_item_selSprite)
    
    local idleCrystalBall = function()
        crystalBallActive:runAction(cc.FadeOut:create(MYTEST2.ballFadeOutDur))
        crystalBallIdle:runAction(cc.FadeIn:create(MYTEST2.ballFadeOutDur))
        --back_item:runAction(cc.FadeOut:create(MYTEST2.ballFadeOutDur))
        --start_item:runAction(cc.FadeIn:create(MYTEST2.ballFadeOutDur))
    end
    local hideBackShowStart = function()
        back_item:setVisible(false)
        start_item:setVisible(true)
    end
    local hideStartShowBack = function()
        back_item:setVisible(true)
        start_item:setVisible(false)
    end
    local activateCrystalBall = function()
        ground_bg:enableTouching()
        crystalBallActive:runAction(cc.FadeIn:create(MYTEST2.ballFadeOutDur))
        crystalBallIdle:runAction(cc.FadeOut:create(MYTEST2.ballFadeOutDur))
        hideStartShowBack()
    end
    local callback = function()
        ground_bg:stopRefreshing()
        ground_bg:disableTouching()
        ground_bg:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.MoveTo:create(
                MYTEST2.backToStartDur,
                cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, MYTEST2.groundYOffset))),
            cc.CallFunc:create(idleCrystalBall),
            cc.DelayTime:create(MYTEST2.ballFadeOutDur),
            cc.CallFunc:create(hideBackShowStart)))
    end
    -- CocosDenshionTest.lua (111)
    back_item:registerScriptTapHandler(callback)
    back_item:setPosition(cc.p(200, 200))
    start_item:registerScriptTapHandler(activateCrystalBall)
    start_item:setAnchorPoint(cc.p(0.5, 0))
    start_item:setPosition(cc.p(size.width / 2, MYTEST2.groundYOffset))
    start_item:setVisible(false)
    local menu = cc.Menu:create(back_item, start_item)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu)
    
    return scene
end
