require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'

Gameplay = {}

function Gameplay.boot(self, parent, gameOverCallback)
    local menu
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        menu:removeFromParentAndCleanup(true)
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
    cho:setPosition(cc.p(0, 100))
    parent:addChild(cho)
end
