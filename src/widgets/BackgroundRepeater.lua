require 'Cocos2d'

BackgroundRepeater = {}

function BackgroundRepeater.create(self, width, frame, anchor, delta, scale)
    anchor = anchor or cc.p(0, 1)
    delta = delta or 0
    scale = scale or 1
    local layer = cc.Layer:create()
    local size = cc.Director:getInstance():getVisibleSize()
    layer:setContentSize(cc.size(width, size.height))

    local getDelta
    if delta > 0 then
        getDelta = function() return math.random(delta * 0.7, delta * 1.3) end
    elseif delta == 0 then
        getDelta = function() return 0 end
    else
        getDelta = function() return -math.random(-delta * 0.7, -delta * 1.3) end
    end
    
    local frameWidth = globalImageWidth(frame) * scale
    local curp, ct = 0, 0
    while curp < width do
        local sprite = globalSprite(frame)
        if math.random(2) == 1 then sprite:setFlippedX(true) end
        sprite:setAnchorPoint(anchor)
        sprite:setPosition(cc.p(curp, 0))
        sprite:setScale(scale)
        layer:addChild(sprite, ct)
        curp = curp + frameWidth + getDelta()
        ct = ct + 1
    end
    return layer
end
