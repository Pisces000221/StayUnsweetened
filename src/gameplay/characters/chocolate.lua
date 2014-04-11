require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['chocolate'] = {
    charID = 1,
    spriteFrame = 'chocolate',
    velocity = 100,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        local radius = globalImageWidth(self.spriteFrame)
        ret.UNIT = {}
        local distX = 2 * radius * math.pi
        local rotation = 360
        if isGoingLeft then distX = -distX; rotation = -rotation end
        --cclog('distX = ' .. distX)
        --if isGoingLeft then cclog('isGoingLeft') end
        local actionDur = math.abs(distX / self.velocity)
        ret:runAction(cc.RepeatForever:create(cc.Spawn:create(
            cc.RotateBy:create(actionDur, rotation),
            cc.MoveBy:create(actionDur, cc.p(distX, 0))
        )))
        return ret
    end
}
