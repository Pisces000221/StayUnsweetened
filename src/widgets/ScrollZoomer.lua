require 'Cocos2d'
require 'src/global'

ScrollZoomer = {}
ScrollZoomer.doubleTapMaxTime = 0.1
ScrollZoomer.doubleTapMaxDist = 20
ScrollZoomer.zoomDur = 0.2

function ScrollZoomer.create(self, scroll, anchorY)
    local size = cc.Director:getInstance():getVisibleSize()
    local ss = scroll:getContentSize()
    local layer = cc.Layer:create()
    
    local INFP = cc.p(-self.doubleTapMaxDist, -self.doubleTapMaxDist)
    local lastTime = 0
    local lastPos = INFP
    local zoomed = false
    local needZoom = false
    local function t_began(touch, event)
        local location = touch:getLocation()
        if zoomed then
            zoomed = false
            local px = ss.width * location.x / size.width - size.width / 2
            scroll:runAction(cc.EaseSineInOut:create(cc.Spawn:create(
                cc.ScaleTo:create(self.zoomDur, 1),
                cc.MoveTo:create(self.zoomDur,
                    -- keep in bounds
                    cc.p(-math.max(0, math.min(px, ss.width - size.width)), 0))
            )))
            return true
        elseif os.clock() - lastTime <= self.doubleTapMaxTime
          and cc.pGetDistance(location, lastPos) <= self.doubleTapMaxDist then
            -- One more shot, another round
            needZoom = true
        end
        lastTime = os.clock()
        lastPos = location
        return true
    end
    
    local function t_ended(touch, event)
        if needZoom then
            needZoom = false
            local scale = size.width / ss.width
            scroll:runAction(cc.EaseSineInOut:create(cc.Spawn:create(
                cc.ScaleTo:create(self.zoomDur, scale),
                cc.MoveTo:create(self.zoomDur,
                    cc.p(-(ss.width - size.width) / 2, anchorY * 2 - size.height / 2))
            )))
            zoomed = true
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(t_began, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(t_ended, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(false)
    layer:getEventDispatcher()
        :addEventListenerWithSceneGraphPriority(listener, layer)
    
    return layer
end
