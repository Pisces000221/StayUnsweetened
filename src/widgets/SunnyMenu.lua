require 'Cocos2d'
require 'src/global'
require 'src/widgets/SimpleMenuItemSprite'

SunnyMenu = {}
SunnyMenu.rayRadius = 200
SunnyMenu.rayOriginPadding = 76
SunnyMenu.itemInDur = 1
SunnyMenu.itemOutDur = 0.6
SunnyMenu.mainImage = 'constructions'
SunnyMenu.itemImage = 'menu_prop_bg'
SunnyMenu.validYBorder = 120
SunnyMenu.cancellingFadeDur = 0.5
SunnyMenu.cancellingOpacity = 64

function SunnyMenu.create(self, images, callback)
    local size = cc.Director:getInstance():getVisibleSize()
    local node = cc.Node:create()
    local menu = cc.Menu:create()
    local main_r, item_r    -- stores the square width of each image
    local main_r2, item_r2  -- stores the square radius of each image
    local dragger           -- the image that follows the touch
    local selectedIdx
    menu:setPosition(cc.p(0, 0))
    node:addChild(menu)
    local N = #images
    local theta = math.pi / (N + N - 2)
    local items = {}
    node.isActivated = false
    
    local function activate()
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
    
    -- for further uses
    local isCancelling = function(p)
        return p.y < SunnyMenu.validYBorder or p.y > size.height - SunnyMenu.validYBorder
          or (p.x - size.width)*(p.x - size.width) + p.y*p.y < main_r2 * 4
    end
    local isInCancelRegionNow = false
    
    local cancelLayer = cc.Layer:create()
    node:addChild(cancelLayer)
    -- handle touch events
    -- hello.lua (112), thanks again!
    local shouldIdle = false
    local function t_began(touch, event)
        local location = node:convertTouchToNodeSpace(touch)
        if not node.isActivated then return false end
        shouldIdle = location.x * location.x + location.y * location.y > main_r2
        for i = 1, N do
            local px, py = items[i]:getPosition()
            local dx, dy = location.x - px, location.y - py
            local isout = dx * dx + dy * dy > item_r2
            shouldIdle = shouldIdle and isout
            if not isout then
                selectedIdx = i
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
            local p = node:convertTouchToNodeSpace(touch)
            dragger:setPosition(p)
            -- Let it 'Go'! The code doesn't bother me anyway!!
            if isCancelling(p) and not isInCancelRegionNow then
                dragger:runAction(cc.FadeTo:create(
                    SunnyMenu.cancellingFadeDur, SunnyMenu.cancellingOpacity))
                isInCancelRegionNow = true
            elseif not isCancelling(p) and isInCancelRegionNow then
                dragger:runAction(cc.FadeTo:create(
                    SunnyMenu.cancellingFadeDur, 255))
                isInCancelRegionNow = false
            end
        end
    end

    local function t_ended(touch, event)
        if shouldIdle then idle() end
        local p = node:convertTouchToNodeSpace(touch)
        if dragger then
            -- I've got the mo-oo-oo-oo-oo-oo-oo-oo-ooves like 'dragger'!!
            if not isCancelling(p) then
                callback(selectedIdx, node:convertTouchToNodeSpace(touch))
            end
            dragger:removeFromParent()
            dragger = nil
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(t_began, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(t_moved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(t_ended, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    cancelLayer:getEventDispatcher()
        :addEventListenerWithSceneGraphPriority(listener, cancelLayer)
    
    local mainItem = SimpleMenuItemSprite:create(SunnyMenu.mainImage, toggle)
    mainItem:setAnchorPoint(cc.p(1, 0))
    mainItem:setPosition(cc.p(size.width, 0))
    menu:addChild(mainItem)
    main_r = globalImageWidth(SunnyMenu.mainImage) / 2
    main_r2 = main_r * main_r
    item_r = globalImageWidth(SunnyMenu.itemImage) / 2
    item_r2 = item_r * item_r
    
    for i = 1, N do
        items[i] = globalSprite(SunnyMenu.itemImage)
        items[i]:setPosition(cc.p(size.width, 0))
        items[i]:setOpacity(0)
        local icon = globalSprite(images[i])
        local maxside = math.max(globalImageWidth(images[i]), globalImageHeight(images[i]))
        icon:setScale(item_r * 2 * 0.8 / maxside)
        icon:setPosition(cc.p(item_r, item_r))
        items[i]:addChild(icon)
        items[i]:setCascadeOpacityEnabled(true)
        node:addChild(items[i])
    end
    
    return node
end
