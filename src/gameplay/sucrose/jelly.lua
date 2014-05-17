require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['jelly'] = {
    charID = 4,
    spriteFrame = 'jelly',
    velocity = 20,
    maxHP = 3600,
    multiplier = { [FORCE_HEAT] = 1.2, [FORCE_FLOOD] = 0.8 },
    bonus = 12,
    actionTimeRate = 0.6,   -- 60% of time, the sprite is animated
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret:setAnchorPoint(cc.p(0.5, 0))
        ret.UNIT = {}
        local skewX = 30
        local actionDur = skewX / self.velocity * self.actionTimeRate / 2
        local delayTime = skewX / self.velocity * (1 - self.actionTimeRate) / 2
        if isGoingLeft then skewX = -skewX end
        ret:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.EaseSineOut:create(cc.Spawn:create(
                cc.SkewTo:create(actionDur, skewX, 0),
                cc.ScaleTo:create(actionDur, 1, 0.95)
            )), cc.DelayTime:create(delayTime * 0.8),
            cc.EaseSineOut:create(cc.Spawn:create(
                cc.MoveBy:create(actionDur, cc.p(skewX, 0)),
                cc.SkewTo:create(actionDur, 0, 0),
                cc.ScaleTo:create(actionDur, 1)
            )), cc.DelayTime:create(delayTime * 1.2)
        )))
        return ret
    end
}
