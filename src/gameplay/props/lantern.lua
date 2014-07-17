require 'Cocos2d'
require 'src/global'

PROPS = PROPS or {}

local fireTag = 131452541
PROPS['lantern'] = {
    charID = 1035371,
    bodySpriteFrame = 'lantern',
    cost = 70,
    velocity = 132,
    initialForce = { [FORCE_HEAT] = 480, [FORCE_FLOOD] = 0 },
    initialRadius = 330,
    destroyOnFinish = true,
    create = function(self, isGoingLeft)
        isGoingLeft = isGoingLeft or false
        if math.random(2) == 1 then isGoingLeft = not isGoingLeft end
        local lifetime = AMPERE.MAPSIZE / self.velocity
        local ret = globalSprite(self.bodySpriteFrame)
        local body_rect = globalImageRect(self.bodySpriteFrame)
        ret:setAnchorPoint(cc.p(0.5, 0))
        local posY = math.random(230, 288)
        ret.propPositionY = posY
        -- Move!
        local distX = self.velocity
        if isGoingLeft then distX = -distX end
        ret:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.MoveBy:create(1, cc.p(distX, 6)),
            cc.MoveBy:create(1, cc.p(distX, -6)))))
        -- Baby you light up my world like nobody else
        local lightener = cc.ParticleFire:createWithTotalParticles(30)
        lightener:setEmitterMode(cc.PARTICLE_MODE_RADIUS)
        lightener:setStartRadius(0)
        lightener:setEndRadius(20)
        lightener:setPositionType(cc.POSITION_TYPE_GROUPED)
        lightener:setAnchorPoint(cc.p(0.5, 0))
        lightener:setPosition(cc.p(body_rect.width / 2, 30))
        lightener:runAction(cc.ScaleTo:create(lifetime * 3, 0))
        lightener:setTag(fireTag)
        ret:addChild(lightener)
        ret.UNIT = { lifetime = lifetime }
        return ret
    end,
    update = function(self, dt)
        self.force[FORCE_HEAT] = self.force[FORCE_HEAT]
            - dt / (self.lifetime * 2) * self.initialForce[FORCE_HEAT]
        if self.force[FORCE_HEAT] < 0 then self.force[FORCE_HEAT] = 0 end
    end,
    getForceForPosition = function(self, p, ftype)
        if ftype == FORCE_FLOOD then return 0 end
        local rate = 1 - math.abs(p - self:position()) / self.radius
        if rate <= 0 then return 0
        else return rate * self.force[ftype] end
    end,
    destroy = function(self)
        self:runAction(cc.Sequence:create(
            cc.FadeOut:create(1),
            cc.RemoveSelf:create()))
        self:getChildByTag(fireTag):runAction(cc.ScaleTo:create(1, 0))
        return 1
    end
}
