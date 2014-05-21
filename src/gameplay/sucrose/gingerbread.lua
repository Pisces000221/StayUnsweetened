require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['gingerbread'] = {
    charID = 1,
    spriteFrame = 'gingerbread_house',
    wheelSpriteFrame = 'gingerbread_wheel',
    wheelPosition = { [1] = 0.2, [2] = 0.8 },
    velocity = 24,
    maxHP = 3000,
    multiplier = { [FORCE_HEAT] = 0.3, [FORCE_FLOOD] = 0.3 },
    bonus = 60,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret.UNIT = {}
        local w = globalImageWidth(self.spriteFrame)
        local wheels = {}
        ret.wheelImageRadius = globalImageWidth(self.wheelSpriteFrame) * 0.5
        ret.propPositionY = ret.wheelImageRadius - 5
        local distX = 2 * ret.wheelImageRadius * math.pi
        local rotation = 360
        local actionDur = distX / self.velocity
        if isGoingLeft then distX = -distX; rotation = -rotation end
        for i = 1, 2 do
            wheels[i] = globalSprite(self.wheelSpriteFrame)
            wheels[i]:setPosition(cc.p(w * self.wheelPosition[i], 0))
            ret:addChild(wheels[i])
            wheels[i]:runAction(cc.RepeatForever:create(
                cc.RotateBy:create(actionDur, rotation)))
        end
        ret:setCascadeOpacityEnabled(true)
        ret:runAction(cc.RepeatForever:create(
            cc.MoveBy:create(actionDur, cc.p(distX, 0))))
        return ret
    end
}
