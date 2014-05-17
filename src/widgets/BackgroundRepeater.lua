require 'Cocos2d'

BackgroundRepeater = {}

function BackgroundRepeater.create(self, width, frame, anchor)
    anchor = anchor or cc.p(0, 1)
    local layer = cc.Layer:create()
    local size = cc.Director:getInstance():getVisibleSize()
    layer:setContentSize(cc.size(width, size.height))
    
    local frameWidth = globalImageWidth(frame)
    local curp, ct = 0, 0
    while curp < width do
        local sprite = globalSprite(frame)
        if math.random(2) == 1 then sprite:setFlippedX(true) end
        sprite:setAnchorPoint(anchor)
        --cclog(sprite:getContentSize().width)
        sprite:setPosition(cc.p(curp, 0))
        layer:addChild(sprite, ct)
        curp = curp + frameWidth
        ct = ct + 1
    end
    return layer
end
