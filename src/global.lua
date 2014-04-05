require 'Cocos2d'

function globalSpriteFrame(frameName)
    return cc.Sprite:createWithSpriteFrame(
        cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName))
end
