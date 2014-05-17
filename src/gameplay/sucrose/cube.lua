require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['cube'] = {
    charID = 3,
    spriteFrame = 'cube',
    velocity = 100,
    maxHP = 1200,
    multiplier = { [FORCE_HEAT] = 1, [FORCE_FLOOD] = 1 },
    bonus = 19,
    actionTimeRate = 0.6,   -- 60% of time, the sprite is animated
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret.UNIT = {}
        ret.imageDiametre = globalImageWidth(self.spriteFrame)
        local rotation = 90
        if isGoingLeft then rotation = -rotation end
        local actionDur = ret.imageDiametre / self.velocity
        local runAnAction = function()
            local px, py = ret:getPosition()
            local anchor = cc.p(px + ret.imageDiametre / 2,
                py - ret.imageDiametre / 2)
            if isGoingLeft then anchor.x = px - ret.imageDiametre / 2 end
            ret:runAction(cc.Spawn:create(
                MoveRotate90:create(actionDur * self.actionTimeRate, anchor, not isGoingLeft),
                cc.RotateBy:create(actionDur * self.actionTimeRate, rotation)
            ))
        end
        ret:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(actionDur),
            cc.CallFunc:create(runAnAction)
        )))
        return ret
    end
}
