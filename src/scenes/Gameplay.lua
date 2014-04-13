require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'
require 'src/data/set'
require 'src/widgets/SimpleMenuItemSprite'
require 'src/scenes/PausingScene'

Gameplay = {}
Gameplay.scrollTag = 12138
Gameplay.groundYOffset = 80
Gameplay.pauseButtonPadding = cc.p(10, 10)
Gameplay.pauseMenuGetOutDur = 0.6
Gameplay.menuRemoveDelay = Gameplay.pauseMenuGetOutDur

function Gameplay.boot(self, parent, gameOverCallback)
    local size = cc.Director:getInstance():getVisibleSize()
    local menu, pause_item
    local scroll = parent:getChildByTag(Gameplay.scrollTag)
    local enemies = set.new()
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        pause_item:runAction(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.pauseMenuGetOutDur,
            cc.p(0, pause_item:getContentSize().height + Gameplay.pauseButtonPadding.y)), 0.8))
        menu:runAction(cc.Sequence:create(
            cc.DelayTime:create(Gameplay.menuRemoveDelay),
            cc.CallFunc:create(function() menu:removeFromParent() end)))
        while #enemies > 0 do
            local e = enemies:pop()
            local dx = math.random(size.width / 3) + size.width
            if math.random(2) == 1 then dx = -dx end
            e:runAction(cc.Sequence:create(
                cc.MoveBy:create(1, cc.p(dx, 0)),
                cc.CallFunc:create(function() e:removeFromParent() end)))
        end
        gameOverCallback()
    end
    
    local pauseCallback = function()
        pause_item:setVisible(false)
        local pix, piy = pause_item:getPosition()
        cc.Director:getInstance():pushScene(PausingScene:create(
            pause_item:getAnchorPoint(), cc.p(pix, piy)))
        pause_item:setVisible(true)
    end

    local back_item = cc.MenuItemLabel:create(
        cc.Label:createWithTTF(globalTTFConfig(30), 'GO BACK'))
    back_item:registerScriptTapHandler(gameOver)
    back_item:setPosition(cc.p(200, 200))
    pause_item = SimpleMenuItemSprite:create('pause', pauseCallback)
    pause_item:setAnchorPoint(cc.p(0, 1))
    pause_item:setPosition(cc.p(Gameplay.pauseButtonPadding.x,
        size.height - Gameplay.pauseButtonPadding.y))
    pause_item:setOpacity(PausingScene.iconOpacity)
    menu = cc.Menu:create(back_item, pause_item)
    menu:setPosition(cc.p(0, 0))
    parent:addChild(menu)
    
    local cho = SUCROSE.create('chocolate', false)
    cho:setPosition(cc.p(AMPERE.MAPSIZE / 2, Gameplay.groundYOffset + cho.imageRadius))
    enemies:append(cho)
    scroll:addChild(cho)
end
