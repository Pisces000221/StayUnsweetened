require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['gingerbread'] = {
    charID = 1,
    spriteFrame = 'gingerbread_house',
    wheelSpriteFrame = 'gingerbread_wheel',
    wheelPosition = { [1] = 0.2, [2] = 0.8 },
    velocity = 24,
    maxHP = 6000,
    multiplier = { [FORCE_HEAT] = 0.3, [FORCE_FLOOD] = 0.3 },
    bonus = 40,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret.UNIT = { explode = self.explode }
        ret.destroy = self.explode
        ret.getReacherAction = self.getReacherAction
        local w = globalImageWidth(self.spriteFrame)
        local wheels = {}
        ret.wheelImageRadius = globalImageWidth(self.wheelSpriteFrame) * 0.5
        ret.propPositionY = ret.wheelImageRadius * 2 * 1.8
        ret:setScale(1.8)
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
    end,
    getReacherAction = function(self)
        return cc.Sequence:create(
            cc.CallFunc:create(function() self:destroy() end),
            cc.FadeOut:create(3))
    end,
    explode = function(self)
        local p0 = self:getPositionX()
        local loopCt = math.random(8, 15)
        for i = 1, loopCt do
            local p = p0 + math.random(0, 400) - 200
            if math.abs(p - AMPERE.MAPSIZE / 2) < 800 then
                if p < AMPERE.MAPSIZE / 2 then p = p - 800
                else p = p + 800 end
            end
            local child = SUCROSE.create(
                AMPERE.WAVES.names[math.random(1, #AMPERE.WAVES.names - 1)],
                p > AMPERE.MAPSIZE / 2)
            --cclog(p - p0)
            self:getParent():addToEnemy(child, p0)
            child:runAction(cc.Sequence:create(
                cc.CallFunc:create(function() child.UNIT.friendly = true end),
                cc.JumpBy:create(1.2, cc.p(p - p0, 0), 150, 1),
                cc.CallFunc:create(function() child.UNIT.friendly = false end)))
        end
    end
}
