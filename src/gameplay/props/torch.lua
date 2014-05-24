require 'Cocos2d'
require 'src/global'

PROPS = PROPS or {}

local fireTag = 1314520
PROPS['torch'] = {
    charID = 1035369,
    bodySpriteFrame = 'torch_body',
    cost = 20,
    lifetime = 30,
    initialForce = { [FORCE_HEAT] = 350, [FORCE_FLOOD] = 0 },
    initialRadius = 400,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.bodySpriteFrame)
        ret:setAnchorPoint(cc.p(0.5, 0))
        ret.propPositionY = 0
        local lightener = cc.ParticleFire:createWithTotalParticles(30)
        lightener:setEmitterMode(cc.PARTICLE_MODE_RADIUS)
        lightener:setStartRadius(0)
        lightener:setEndRadius(20)
        -- http://www.cocoachina.com/ask/questions/show/4142
        lightener:setPositionType(cc.POSITION_TYPE_GROUPED)
        local body_rect = globalImageRect(self.bodySpriteFrame)
        lightener:setAnchorPoint(cc.p(0.5, 0))
        lightener:setPosition(cc.p(body_rect.width / 2, body_rect.height))
        lightener:runAction(cc.ScaleTo:create(self.lifetime, 0))
        lightener:setTag(fireTag)
        ret:addChild(lightener)
        ret:runAction(cc.Sequence:create(
            cc.DelayTime:create(self.lifetime + 5),
            cc.CallFunc:create(function() ret:destroy() end)))
        ret.UNIT = { lifetime = self.lifetime }
        return ret
    end,
    update = function(self, dt)
        self.force[FORCE_HEAT] = self.force[FORCE_HEAT]
            - dt / self.lifetime * self.initialForce[FORCE_HEAT]
        if self.force[FORCE_HEAT] < 0 then self.force[FORCE_HEAT] = 0 end
        self.radius = self.radius - dt / self.lifetime * self.initialRadius
    end,
    getForceForPosition = function(self, p, ftype)
        local rate = 1 - math.abs(p - self:position()) / self.radius
        if rate <= 0 then return 0
        else return rate * self.force[ftype] end
    end,
    destroy = function(self)
        local rotateAngle = 90
        if math.random(2) == 1 then rotateAngle = -90 end
        self:runAction(cc.Spawn:create(cc.EaseQuadraticActionIn:create(
            cc.RotateBy:create(1, rotateAngle)),
            cc.FadeOut:create(1)))
        self:getChildByTag(fireTag):runAction(
            cc.ScaleTo:create(1, 0))
        return 1
    end
}
