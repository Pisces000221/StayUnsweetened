require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['candyfloss'] = {
    charID = 6,
    spriteFrame = 'candyfloss',
    velocity = 200,
    maxHP = 1500,
    multiplier = { [FORCE_HEAT] = 1.3, [FORCE_FLOOD] = 1 },
    bonus = 30,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret.propPositionY = 240
        local rsize = ret:getContentSize()
        ret.UNIT = { friendly = true }
        local distX = self.velocity
        if isGoingLeft then distX = -distX end
        ret:runAction(cc.RepeatForever:create(
            cc.MoveBy:create(1, cc.p(distX, 0))))
        local balloon = globalSprite('balloon')
        balloon:setAnchorPoint(cc.p(0.5, 0))
        balloon:setPosition(cc.p(rsize.width / 2, rsize.height - 30))
        balloon:setColor(cc.c3b(math.random(64, 255),
            math.random(64, 255), math.random(64, 255)))
        ret:addChild(balloon, -1)
        return ret
    end
}
