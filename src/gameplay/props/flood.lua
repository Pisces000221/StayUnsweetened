require 'Cocos2d'
require 'src/global'

PROPS = PROPS or {}

PROPS['flood'] = {
    charID = 1035372,
    bodySpriteFrame = nil,
    cost = 10,
    velocity = 1000,
    initialForce = { [FORCE_HEAT] = 0, [FORCE_FLOOD] = 300 },
    initialRadius = 0,
    height = 24,
    create = function(self, isGoingLeft)
        isGoingLeft = isGoingLeft or false
        local lifetime = AMPERE.MAPSIZE * 2 / self.velocity
        local ret = puritySprite(1, self.height, cc.c3b(192, 192, 255))
        ret:setAnchorPoint(cc.p(0.5, 0))
        ret:setOpacity(192)
        -- Move!
        local distX = self.velocity
        if isGoingLeft then distX = -distX end
        ret:runAction(cc.ScaleBy:create(lifetime, AMPERE.MAPSIZE * 2, 1))
        ret.UNIT = { lifetime = lifetime, age = 0,
            getRadius = function() return ret:getScaleX() end }
        --cclog(lifetime)
        return ret
    end,
    update = function(self, dt)
        self.age = self.age + dt
        if self.age > self.lifetime then self.force[FORCE_FLOOD] = 0 end
    end,
    getForceForPosition = function(self, p, ftype)
        if ftype == FORCE_HEAT then return 0 end
        local radius = self:getRadius()
        if math.abs(p - self:position()) > radius then return 0
        else return self.force[ftype] end
    end,
    destroy = function(self)
        self:runAction(cc.FadeOut:create(1))
        return 1
    end
}
