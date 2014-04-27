require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['cane'] = {
    charID = 2,
    spriteFrame = 'cane',
    velocity = 100,
    maxHP = 1000,
    multiplier = { [FORCE_HEAT] = 1, [FORCE_FLOOD] = 1 },
    bonus = 15,
    actionTimeRate = 0.6,   -- 60% of time, the sprite is animated
    jumpHeight = 80,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret:setAnchorPoint(cc.p(0.5, 0))
        ret.UNIT = {}
        local jumpX = 100
        local actionDur = jumpX / self.velocity
        if isGoingLeft then jumpX = -jumpX end
        ret:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.JumpBy:create(actionDur * self.actionTimeRate,
                cc.p(jumpX, 0), self.jumpHeight, 1),
            cc.DelayTime:create(actionDur * (1 - self.actionTimeRate))
        )))
        return ret
    end
}
