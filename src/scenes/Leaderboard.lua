require 'Cocos2d'
require 'src/global'
require 'src/widgets/BackgroundRepeater'
require 'src/scenes/StartupScene'

Leaderboard = {}
Leaderboard.circleRadius = 30
Leaderboard.circleMoveX = 60
Leaderboard.medalColour = {
    [1] = cc.c4f(1, 1, 0.3, 1), [2] = cc.c4f(0.7, 0.7, 0.7, 1),
    [3] = cc.c4f(0.9, 0.6, 0.1, 1) }
Leaderboard.numColour = {
    [1] = cc.c3b(0, 0, 0), [2] = cc.c3b(0, 0, 0), [3] = cc.c3b(0, 0, 0) }

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

    local circles = cc.DrawNode:create()
    circles:setPositionX(-Leaderboard.circleMoveX)
    scene:addChild(circles, 62)
    local lines = {}
    local segmentRightmostX = size.width - Leaderboard.circleRadius * 1.618
    for i = 1, 10 do
        local deltaX = 0
        if i % 2 == 0 then deltaX = 18 end
        local centre = cc.p(Leaderboard.circleRadius * 1.5 + deltaX,
            (size.height - 64) / 11 * (11 - i))
        local mcolour = cc.c4f(0.4, 0.4, 0.4, 1)
        local ncolour = cc.c3b(255, 255, 255)
        if i <= #Leaderboard.medalColour then
            mcolour = Leaderboard.medalColour[i]
            ncolour = Leaderboard.numColour[i]
        end
        circles:drawDot(centre, Leaderboard.circleRadius, mcolour)
        local num = globalLabel(tostring(i), Leaderboard.circleRadius * 1.618)
        num:setPosition(centre)
        num:setColor(ncolour)
        circles:addChild(num)
        -- draw lines
        lines[i] = cc.DrawNode:create()
        local tot_dt = -0.1 * i
        local cur_i = i
        lines[i].entry = scene:getScheduler():scheduleScriptFunc(function(dt)
            tot_dt = tot_dt + dt
            if tot_dt <= 0 then return
            elseif tot_dt >= 1 then
                tot_dt = 1
                scene:getScheduler():unscheduleScriptEntry(lines[i].entry)
            end
            lines[i]:clear()
            lines[i]:drawSegment(centre,
                cc.p((segmentRightmostX - centre.x) * tot_dt / 1 + centre.x, centre.y),
                Leaderboard.circleRadius * 0.809, cc.c4f(0, 0, 0, 0.7))
        end, 0, false)
        scene:addChild(lines[i], 61)
        lines[i].label = globalLabel('', Leaderboard.circleRadius * 1.618)
        lines[i].label:setPosition(cc.p(centre.x + Leaderboard.circleRadius * 3, centre.y))
        lines[i]:addChild(lines[i].label)
    end
    circles:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(1.5, cc.p(Leaderboard.circleMoveX, 0)), 0.8))

    getHighScores = function(start_rank)
        local entry = 0
        downloadFile('http://cg-u2.cn.gp/su/get_highscore.php', '2.txt')
        entry = scene:getScheduler():scheduleScriptFunc(function()
            if not updaterIsFinished() then return end
            scene:getScheduler():unscheduleScriptEntry(entry)
            local r = dofile('2.txt')
            cclogtable(r)
            for i = 1, 10 do
                lines[i].label:setString(r[i].name)
                lines[i].label:runAction(cc.FadeIn:create(0.4))
            end
        end, 1, false)
    end
    getHighScores(1)

    return scene
end
