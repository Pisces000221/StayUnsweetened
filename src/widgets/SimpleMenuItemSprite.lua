require 'Cocos2d'
require 'src/global'

SimpleMenuItemSprite = {}

function SimpleMenuItemSprite.create(self, frame, callback)
    local selSprite = globalSprite(frame)
    selSprite:setColor(cc.c3b(128, 128, 128))
    local item = cc.MenuItemSprite:create(globalSprite(frame), selSprite)
    item:registerScriptTapHandler(callback)
    return item
end
