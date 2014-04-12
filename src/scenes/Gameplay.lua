require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'
require 'src/data/set'

Gameplay = {}
Gameplay.scrollTag = 12138
Gameplay.groundYOffset = 80
--Gameplay.groundHeight = 80

function Gameplay.boot(self, parent, gameOverCallback)
    local size = cc.Director:getInstance():getVisibleSize()
    local menu
    local scroll = parent:getChildByTag(Gameplay.scrollTag)
    local enemies = set.new()
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        menu:removeFromParent()
        while #enemies > 0 do
            local e = enemies:pop()
            local dx = math.random(size.width / 3) + size.width
            --for i = 1, 10 do cclog(math.random(2)) end
            if math.random(2) == 1 then dx = -dx end
            e:runAction(cc.Sequence:create(
                cc.MoveBy:create(1, cc.p(dx, 0)),
                cc.CallFunc:create(function() e:removeFromParent() end)))
        end
        gameOverCallback()
    end

    local back_item = cc.MenuItemLabel:create(
        cc.Label:createWithTTF(globalTTFConfig(30), 'GO BACK'))
    back_item:registerScriptTapHandler(gameOver)
    back_item:setPosition(cc.p(200, 200))
    menu = cc.Menu:create(back_item)
    menu:setPosition(cc.p(0, 0))
    parent:addChild(menu)
    
    local cho = SUCROSE.create('chocolate', false)
    cho:setPosition(cc.p(AMPERE.MAPSIZE / 2, Gameplay.groundYOffset + cho.imageRadius))
    enemies:append(cho)
    cclogtable(enemies)
    scroll:addChild(cho)
end
