require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['fruit'] = {
    charID = 5,
    spriteFrame = 'fruit',
    velocity = 144,
    maxHP = 1800,
    multiplier = { [FORCE_HEAT] = 1.4, [FORCE_FLOOD] = 0.85 },
    bonus = 12,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret.UNIT = {}
        ret.imageRadius = globalImageWidth(self.spriteFrame) * 0.5
        local distX = 2 * ret.imageRadius * math.pi
        local rotation = 360
        local actionDur = distX / self.velocity
        if isGoingLeft then distX = -distX; rotation = -rotation end
        ret:runAction(cc.RepeatForever:create(cc.Spawn:create(
            cc.RotateBy:create(actionDur, rotation),
            cc.MoveBy:create(actionDur, cc.p(distX, 0))
        )))
        ret:setColor(cc.c3b(math.random(144, 255),
            math.random(144, 255), math.random(144, 255)))
        return ret
    end
}
