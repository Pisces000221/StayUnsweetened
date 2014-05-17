require 'Cocos2d'
require 'src/global'

PROPS = PROPS or {}

local rainTag = 1314521
PROPS['cloud'] = {
    charID = 1035370,
    bodySpriteFrame = 'cloud',
    cost = 30,
    lifetime = 25,
    initialForce = { [FORCE_HEAT] = 0, [FORCE_FLOOD] = 350 },
    initialRadius = nil,
    create = function(self, isGoingLeft)
        if self.initialRadius == nil then
            self.initialRadius = globalImageWidth(self.bodySpriteFrame)
        end
        local ret = globalSprite(self.bodySpriteFrame)
        local body_rect = globalImageRect(self.bodySpriteFrame)
        ret:setAnchorPoint(cc.p(0.5, 0))
        local posY = math.random(280, 360)
        ret.propPositionY = posY
        ret:runAction(cc.FadeOut:create(self.lifetime * 3))
        local rain = cc.ParticleRain:create()
        rain:setEmitterMode(cc.PARTICLE_MODE_GRAVITY)
        rain:setPositionType(cc.POSITION_TYPE_GROUPED)
        rain:setSpeed(300)
        rain:setStartSize(16)
        --m.bianceng.cn/OS/extra/201306/36789.htm
        rain:setLife((posY + body_rect.height / 2) / 300)
        rain:setScaleX(body_rect.width
            / cc.Director:getInstance():getVisibleSize().width)
        rain:setAnchorPoint(cc.p(0.5, 1))
        rain:setPosition(cc.p(body_rect.width / 2, body_rect.height / 2))
        local total_dt = 0
        local entry = 0
        entry = rain:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt >= self.lifetime then
                    rain:getScheduler():unscheduleScriptEntry(entry)
                    rain:removeFromParent()
                else rain:setStartSize(16 * (1 - total_dt / self.lifetime)) end
            end, 0, false)
        rain:setTag(rainTag)
        rain.entry = entry
        ret:addChild(rain)
        ret.UNIT = { lifetime = self.lifetime }
        return ret
    end,
    update = function(self, dt)
        self.force[FORCE_FLOOD] = self.force[FORCE_FLOOD]
            - dt / self.lifetime * self.initialForce[FORCE_FLOOD]
        if self.force[FORCE_FLOOD] < 0 then self.force[FORCE_FLOOD] = 0 end
    end,
    getForceForPosition = function(self, p, ftype)
        if ftype == FORCE_HEAT
         or math.abs(p - self:position()) > self.radius then
            return 0
        else return self.force[FORCE_FLOOD] end
    end,
    destroy = function(self)
        local action = cc.FadeTo:create(1, 0)
        self:runAction(action)
        local rain = self:getChildByTag(rainTag)
        if rain then
            rain:getScheduler():unscheduleScriptEntry(rain.entry)
            rain:stopSystem()
        end
        return 1
    end
}
