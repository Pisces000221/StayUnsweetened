require 'Cocos2d'
require 'src/global'
require 'src/widgets/SimpleMenuItemSprite'

SunnyMenu = {}
SunnyMenu.rayRadius = 200
SunnyMenu.rayOriginPadding = 30
SunnyMenu.itemInDur = 1
SunnyMenu.itemOutDur = 0.6

function SunnyMenu.create(self, images, callbacks)
    local size = cc.Director:getInstance():getVisibleSize()
    local node = cc.Node:create()
    local menu = cc.Menu:create()
    local r2 = {}   -- stores the square radius of each image
    local dragger   -- the image that follows the touch
    menu:setPosition(cc.p(0, 0))
    node:addChild(menu)
    if images[0] == nil then
        cclog('WARNING: SUNNY: didn\'t give the main image')
        images[0] = ''
    end
    local N = #images
    local theta = math.pi / (N + N - 2)
    local items = {}
    node.isActivated = false
    
    local function activate()
        cclog('SUNNY: activated')
        node.isActivated = true
        for i = 1, N do
            items[i]:runAction(cc.Spawn:create(
                cc.FadeIn:create(SunnyMenu.itemInDur),
                cc.EaseElasticOut:create(cc.MoveBy:create(SunnyMenu.itemInDur,
                    cc.p(-SunnyMenu.rayRadius * math.sin((i - 1) * theta) - SunnyMenu.rayOriginPadding, 
                      SunnyMenu.rayRadius * math.cos((i - 1) * theta) + SunnyMenu.rayOriginPadding)), 0.8)
            ))
        end
    end
    local function idle()
        cclog('SUNNY: set idle')
        node.isActivated = false
        for i = 1, N do
            items[i]:runAction(cc.Spawn:create(
                cc.FadeOut:create(SunnyMenu.itemOutDur),
                cc.EaseElasticIn:create(cc.MoveBy:create(SunnyMenu.itemOutDur,
                    cc.p(SunnyMenu.rayRadius * math.sin((i - 1) * theta) + SunnyMenu.rayOriginPadding, 
                      -SunnyMenu.rayRadius * math.cos((i - 1) * theta) - SunnyMenu.rayOriginPadding)), 1.1)
            ))
        end
    end
    local function toggle()
        if node.isActivated then idle()
        else activate() end
    end
    
    local cancelLayer = cc.Layer:create()
    node:addChild(cancelLayer)
    -- handle touch events
    -- hello.lua (112), thanks again!
    local shouldIdle = false
    local function t_began(touch, event)
        local location = node:convertTouchToNodeSpace(touch)
        if not node.isActivated then return false end
        shouldIdle = location.x * location.x + location.y * location.y > r2[0]
        for i = 1, N do
            local px, py = items[i]:getPosition()
            local dx, dy = location.x - px, location.y - py
            local isout = dx * dx + dy * dy > r2[i]
            shouldIdle = shouldIdle and isout
            if not isout then
                dragger = globalSprite(images[i])
                dragger:setPosition(location)
                cancelLayer:addChild(dragger)
                return true
            end
        end
        return true
    end

    local function t_moved(touch, event)
        if dragger then
            dragger:setPosition(node:convertTouchToNodeSpace(touch))
        end
    end

    local function t_ended(touch, event)
        local location = touch:getLocation()
        if shouldIdle then idle() end
        if dragger then dragger:removeFromParent(); dragger = nil end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(t_began, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(t_moved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(t_ended, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    cancelLayer:getEventDispatcher()
        :addEventListenerWithSceneGraphPriority(listener, cancelLayer)
    
    local mainItem = SimpleMenuItemSprite:create(images[0], toggle)
    menu:addChild(mainItem)
    r2[0] = globalImageWidth(images[0]) / 2
    r2[0] = r2[0] * r2[0]
    
    for i = 1, N do
        items[i] = globalSprite(images[i])
        items[i]:setOpacity(0)
        r2[i] = globalImageWidth(images[i]) / 2
        r2[i] = r2[i] * r2[i]
        node:addChild(items[i])
    end
    
    return node
end
