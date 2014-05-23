require 'Cocos2d'
require 'src/global'

SUCROSE = SUCROSE or {}

SUCROSE['candyfloss'] = {
    charID = 6,
    spriteFrame = 'candyfloss',
    velocity = 200,
    maxHP = 1500,
    multiplier = { [FORCE_HEAT] = 1.3, [FORCE_FLOOD] = 1 },
    bonus = 30,
    create = function(self, isGoingLeft)
        local ret = globalSprite(self.spriteFrame)
        ret.propPositionY = 240
        local rsize = ret:getContentSize()
        ret.UNIT = { friendly = true }
        local distX = self.velocity
        if isGoingLeft then distX = -distX end
        ret:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.MoveBy:create(1.3, cc.p(distX * 1.3, 50)),
            cc.MoveBy:create(1.3, cc.p(distX * 1.3, -50)))))
        ret:setColor(cc.c3b(math.random(216, 255),
            math.random(216, 255), math.random(216, 255)))
        local balloon = globalSprite('balloon')
        balloon:setAnchorPoint(cc.p(0.5, 0))
        if isGoingLeft then
            balloon:setPosition(cc.p(rsize.width / 2 - 1, rsize.height - 24))
        else
            balloon:setPosition(cc.p(rsize.width / 2 + 1, rsize.height - 24))
        end
        balloon:setColor(cc.c3b(math.random(64, 255),
            math.random(64, 255), math.random(64, 255)))
        balloon:setFlippedX(isGoingLeft)
        -- detect touches
        balloon.bonusGot = false
        local function onTouchBegan(touch, event)
            local p = balloon:convertToNodeSpace(touch:getLocation())
            local s0 = balloon:getContentSize()
            if ret.UNIT.HP > 0 or balloon.bonusGot or
             not cc.rectContainsPoint(cc.rect(0, 0, s0.width, s0.height), p) then
                return false
            end
            local balloonBonus = math.random(3, 10)
            balloon.bonusGot = true
            balloon:setVisible(false)
            local bub = globalLabel('+' .. balloonBonus .. '%', 36)
            if balloonBonus > _G['BALLOON_BONUS'] then
                _G['BALLOON_BONUS'] = balloonBonus
            end
            bub:setPosition(cc.p(ret:getPosition()))
            ret:getParent():addChild(bub, 1024)
            bub:runAction(cc.Sequence:create(cc.Spawn:create(
                cc.EaseSineOut:create(cc.MoveBy:create(Gameplay.bonusBubbleMoveDur, cc.p(0, 60))),
                cc.FadeOut:create(Gameplay.bonusBubbleFadeDur)),
                cc.RemoveSelf:create()))
            return true
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        balloon:getEventDispatcher()
            :addEventListenerWithSceneGraphPriority(listener, balloon)
        ret:addChild(balloon, 1)
        return ret
    end
}
