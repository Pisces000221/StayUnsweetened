require 'Cocos2d'
require 'src/global'

MYTEST2 = {}

function MYTEST2.create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    
    cclog('MYTEST2: creating sprite1')
    local sprite1 = globalSpriteFrame('chocolate_1')
    sprite1:setPosition(cc.p(100, 200))
    cclog('MYTEST2: creating sprite2')
    local sprite2 = globalSpriteFrame('land')
    sprite2:setPosition(cc.p(300, 200))
    cclogtable(sprite1)
    scene:addChild(sprite1)
    scene:addChild(sprite2)
    
    return scene
end
