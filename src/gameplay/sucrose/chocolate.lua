require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['chocolate'] = {
    charID = 1,
    spriteFrame = 'chocolate',
    velocity = 100,
    maxHP = 1200,
    multiplier = { [FORCE_HEAT] = 1, [FORCE_FLOOD] = 1 },
    bonus = 9,
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
        return ret
    end
}
