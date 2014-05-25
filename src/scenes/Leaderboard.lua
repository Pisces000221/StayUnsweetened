require 'Cocos2d'
require 'src/global'
require 'src/widgets/BackgroundRepeater'
require 'src/scenes/StartupScene'

Leaderboard = {}

function Leaderboard.create(self, anchor, pos, callback)
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    local sky = Sky:create()
    scene:addChild(sky, -1)
    local parallax_width = 3200
    local function create_parallax_bg()
        local parallax_bg = cc.ParallaxNode:create()
        parallax_bg.width = {}
        parallax_bg:setPosition(cc.p(0, -20))
        for i = 1, #StartupScene.parallaxBGRate do
            local r = BackgroundRepeater:create(
                parallax_width, 'parallax_bg_' .. i, cc.p(0, 0),
                StartupScene.parallaxBGDelta[i], StartupScene.parallaxBGScale[i])
            parallax_bg:addChild(r, i, cc.p(StartupScene.parallaxBGRate[i], 1), cc.p(0, 0))
            parallax_bg.width[i] = r:getContentSize().width
        end
        return parallax_bg
    end
    local p1 = create_parallax_bg()
    local p2 = create_parallax_bg()
    scene:addChild(p1, 18)
    scene:addChild(p2, 17)
    scene:getScheduler():scheduleScriptFunc(function(dt)
        p1:setPositionX(p1:getPositionX() - 40 * dt)
        p2:setPositionX(p1:getPositionX() + p1.width[1] - 85)
        if p2:getPositionX() <= -size.width * 2 then
            local t = p1; p1 = p2; p2 = t
        end
    end, 0, false)

    local titleLabel = globalCHNLabel('排行榜 / LEADERBOARD', 64)
    titleLabel:setAnchorPoint(cc.p(0.5, 1))
    titleLabel:setPosition(cc.p(size.width / 2, size.height))
    scene:addChild(titleLabel)

    return scene
end
