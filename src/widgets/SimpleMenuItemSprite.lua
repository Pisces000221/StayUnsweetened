require 'Cocos2d'
require 'src/global'

SimpleMenuItemSprite = {}

function SimpleMenuItemSprite.create(self, frame, callback)
    local selSprite = globalSprite(frame)
    selSprite:setColor(cc.c3b(192, 192, 192))
    local item = cc.MenuItemSprite:create(globalSprite(frame), selSprite)
    item:registerScriptTapHandler(callback)
    return item
end
