require 'Cocos2d'

BackgroundRepeater = {}

function BackgroundRepeater.create(self, width, frame, anchor)
    anchor = anchor or cc.p(0, 1)
    local layer = cc.Layer:create()
    local size = cc.Director:getInstance():getVisibleSize()
    layer:setContentSize(cc.size(width, size.height))
    
    local frameWidth = globalImageWidth(frame)
    local curp = 0
    while curp < width do
        local sprite = globalSprite(frame)
        if math.random(2) == 1 then sprite:setFlipX(true) end
        sprite:setAnchorPoint(anchor)
        sprite:setPosition(cc.p(curp, 0))
        layer:addChild(sprite)
        curp = curp + frameWidth
    end
    return layer
end
