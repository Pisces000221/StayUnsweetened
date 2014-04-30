require 'Cocos2d'
require 'src/global'
require 'src/widgets/SimpleMenuItemSprite'

SunnyMenu = {}
SunnyMenu.rayRadius = 200
SunnyMenu.rayOriginPadding = 60
SunnyMenu.itemShowDur = 1

function SunnyMenu.create(self, images, callbacks)
    local size = cc.Director:getInstance():getVisibleSize()
    local node = cc.Node:create()
    local menu = cc.Menu:create()
    menu:setPosition(cc.p(0, 0))
    node:addChild(menu)
    if images[0] == nil then
        cclog('WARNING: SUNNY: didn\'t give the main image')
        images[0] = ''
    end
    local N = #images
    local theta = math.pi / (N + N - 2)
    local items = {}
    cclog('SUNNY: total %d item(s)', N)
    
    local function toggle()
        for i = 1, N do
            items[i]:runAction(cc.Spawn:create(
                cc.FadeIn:create(SunnyMenu.itemShowDur),
                cc.EaseElasticOut:create(cc.MoveBy:create(SunnyMenu.itemShowDur,
                    cc.p(-SunnyMenu.rayRadius * math.sin((i - 1) * theta) - SunnyMenu.rayOriginPadding, 
                      SunnyMenu.rayRadius * math.cos((i - 1) * theta) + SunnyMenu.rayOriginPadding)), 0.8)
            ))
        end
    end
    
    local mainItem = SimpleMenuItemSprite:create(images[0], toggle)
    menu:addChild(mainItem)
    
    for i = 1, N do
        items[i] = globalSprite(images[i])
        items[i]:setOpacity(0)
        node:addChild(items[i])
    end
    
    return node
end
