require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'
require 'src/gameplay/waves'
require 'src/data/set'
require 'src/widgets/SimpleMenuItemSprite'
require 'src/widgets/SunnyMenu'
require 'src/widgets/WaveToast'
require 'src/scenes/PausingScene'

Gameplay = {}
Gameplay.scrollTag = 12138
Gameplay.groundYOffset = 80
Gameplay.pauseButtonPadding = cc.p(10, 10)
Gameplay.pauseMenuGetOutDur = 0.6
Gameplay.menuRemoveDelay = Gameplay.pauseMenuGetOutDur
Gameplay.sunnyMoveDur = 1

Gameplay.jumpDur = 4
Gameplay.jumpHeight = 100
Gameplay.reacherFadeOutDur = 0.5
Gameplay.reacherJumpCount = 9
Gameplay.reacherYMoveSpeed = 120

Gameplay.constructionOptions =
    { [0] = 'cube', [1] = 'chocolate', [2] = 'pause', [3] = 'restart' }

local function posForCharacter(ch, x)
    return cc.p(x, Gameplay.groundYOffset + ch:getAnchorPointInPoints().y)
end
local function posYForCharacter(ch, x)
    return Gameplay.groundYOffset + ch:getAnchorPointInPoints().y
end

local isScheduleOnceEnabled = true
local scheduleOnceEntries = {}

local function enableScheduleOnce()
    isScheduleOnceEnabled = true
    scheduleOnceEntries = {}
end
local function stopAllScheduleOnce(parent)
    isScheduleOnceEnabled = false
    for k, v in ipairs(scheduleOnceEntries) do
        parent:getScheduler():unscheduleScriptEntry(v)
    end
    scheduleOnceEntries = {}
end

local function scheduleOnce(parent, func, delay)
    if not isScheduleOnceEnabled then return end
    local entry = 0
    local removeEntry = function()
        parent:getScheduler():unscheduleScriptEntry(entry)
        for i = 1, #scheduleOnceEntries do
            if scheduleOnceEntries[i] == entry then
                scheduleOnceEntries[i] = nil
            end
        end
    end
    entry = parent:getScheduler():scheduleScriptFunc(
        function() removeEntry(); func() end, delay, false)
    scheduleOnceEntries[#scheduleOnceEntries + 1] = entry
end

function Gameplay.boot(self, parent, gameOverCallback)
    local size = cc.Director:getInstance():getVisibleSize()
    local menu, pause_item
    local scroll = parent:getChildByTag(Gameplay.scrollTag)
    local enemies = set.new()
    local props = set.new()
    local tickScheduleEntry = 0
    local tick
    local construct         -- The menu to display construction options
    enableScheduleOnce()
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        parent:getScheduler():unscheduleScriptEntry(tickScheduleEntry)
        stopAllScheduleOnce(parent)
        -- reset display
        pause_item:runAction(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.pauseMenuGetOutDur,
            cc.p(0, pause_item:getContentSize().height + Gameplay.pauseButtonPadding.y)), 0.8))
        menu:runAction(cc.Sequence:create(
            cc.DelayTime:create(Gameplay.menuRemoveDelay),
            cc.CallFunc:create(function() menu:removeFromParent() end)))
        construct:runAction(cc.Sequence:create(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.sunnyMoveDur, cc.p(0, -SunnyMenu.rayRadius)), 1),
            cc.CallFunc:create(function() construct:removeFromParent() end)))
        -- reset data
        while #props > 0 do
            local p = props:pop()
            p:runAction(cc.Sequence:create(
                cc.DelayTime:create(p:destroy()),
                cc.CallFunc:create(function() p:removeFromParent() end)))
        end
        while #enemies > 0 do
            local e = enemies:pop()
            if e.UNIT.reachedBall then
                e:stopAllActions()
                local deltaY = e:getPositionY() - posYForCharacter(e)
                e:runAction(cc.Sequence:create(
                    cc.MoveBy:create(deltaY / Gameplay.reacherYMoveSpeed, cc.p(0, -deltaY)),
                    cc.JumpBy:create(Gameplay.jumpDur, cc.p(0, 0), Gameplay.jumpHeight, Gameplay.reacherJumpCount),
                    cc.FadeOut:create(Gameplay.reacherFadeOutDur),
                    cc.CallFunc:create(function() e:removeFromParent() end)))
            else
                local dx = math.random(size.width / 3) + size.width
                if e.UNIT:position() < AMPERE.MAPSIZE / 2 then dx = -dx end
                e:runAction(cc.Sequence:create(
                    cc.MoveBy:create(1, cc.p(dx, 0)),
                    cc.CallFunc:create(function() e:removeFromParent() end)))
            end
        end
        gameOverCallback()
        cclog('Game Over')
    end
    
    local pauseCallback = function()
        local pix, piy = pause_item:getPosition()
        cc.Director:getInstance():pushScene(PausingScene:create(
            pause_item:getAnchorPoint(), cc.p(pix, piy),
            function(choseToRestart)
                if choseToRestart then gameOver() end
                tickScheduleEntry = parent:getScheduler():scheduleScriptFunc(tick, 0, false)
            end))
        parent:getScheduler():unscheduleScriptEntry(tickScheduleEntry)
    end

    pause_item = SimpleMenuItemSprite:create('pause', pauseCallback)
    pause_item:setAnchorPoint(cc.p(0, 1))
    pause_item:setPosition(cc.p(Gameplay.pauseButtonPadding.x,
        size.height - Gameplay.pauseButtonPadding.y))
    pause_item:setOpacity(PausingScene.iconOpacity)
    menu = cc.Menu:create(pause_item)
    menu:setPosition(cc.p(0, 0))
    parent:addChild(menu)
    
    tick = function(dt)
        local i = 1
        while i <= #enemies do
            local p = enemies[i].UNIT:position()
            local eu = enemies[i].UNIT
            if eu.isGoingLeft and p < (AMPERE.MAPSIZE + AMPERE.BALLWIDTH) / 2
              or not eu.isGoingLeft and p > (AMPERE.MAPSIZE - AMPERE.BALLWIDTH) / 2 then
                eu.reachedBall = true
                print('reacher isgoingleft: ', enemies[i].UNIT.isGoingLeft)
                print('reacher position: ', p)
                gameOver(); return
            end
            for j = 1, #props do
                local pr = props[j]
                local f = pr.UNIT:getForceForPosition(p, FORCE_HEAT) * dt
                if f > 0 then eu:damage(eu.multiplier[FORCE_HEAT] * f) end
                f = pr.UNIT:getForceForPosition(p, FORCE_FLOOD) * dt
                if f > 0 then eu:damage(eu.multiplier[FORCE_FLOOD] * f) end
            end
            if eu.HP <= 0 then
                enemies[i]:runAction(cc.FadeOut:create(1))
                enemies:remove(i)
                -- debug-use only: display score
                local scoreLabel = cc.Label:createWithTTF(globalTTFConfig(36), eu.name)
                scoreLabel:setPosition(cc.p(p, 280))
                scroll:addChild(scoreLabel, 1024)
                scoreLabel:runAction(cc.Sequence:create(cc.Spawn:create(
                    cc.EaseSineOut:create(cc.MoveBy:create(1.4, cc.p(0, 60))),
                    cc.FadeOut:create(2)),
                    cc.CallFunc:create(function() scoreLabel:removeFromParent() end)))
                i = i - 1
            end
            i = i + 1
        end
        for i = 1, #props do props[i].UNIT:update(dt) end
    end
    -- hello.lua (75)
    tickScheduleEntry = parent:getScheduler():scheduleScriptFunc(tick, 0, false)
    
    -- Add the construction menu
    construct = SunnyMenu:create(
        Gameplay.constructionOptions,
        function(idx) cclog(idx) end)
    --construct:setAnchorPoint(cc.p(1, 0))
    local sunnyMain_radius = globalImageWidth(Gameplay.constructionOptions[0]) / 2
    construct:setPosition(cc.p(-sunnyMain_radius, -SunnyMenu.rayRadius + sunnyMain_radius))
    construct:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(Gameplay.sunnyMoveDur, cc.p(0, SunnyMenu.rayRadius)), 0.6))
    parent:addChild(construct)
    
    WaveToast:show(parent, 3)
    local waveData = AMPERE.WAVES.get(3)
    function createOneEnemy()
        -- Generate parametres
        local isGoingLeft = math.random(2) == 1
        local checked, checkCount = {}, 0
        for i = 1, #AMPERE.WAVES.names do
            checked[i] = waveData[AMPERE.WAVES.names[i]] == 0
            if checked[i] then checkCount = checkCount + 1 end
        end
        -- Randomly select a type
        local enemyType = math.random(1, #AMPERE.WAVES.names)
        while waveData[AMPERE.WAVES.names[enemyType]] <= 0 do
            enemyType = math.random(1, #AMPERE.WAVES.names)
        end
        local enemyName = AMPERE.WAVES.names[enemyType]
        -- Put that into the scene
        local e = SUCROSE.create(enemyName, isGoingLeft)
        local p0 = -AMPERE.EXTRAMAPSIZE
        if isGoingLeft then p0 = AMPERE.MAPSIZE + AMPERE.EXTRAMAPSIZE end
        e:setPosition(posForCharacter(e, p0))
        enemies:append(e)
        scroll:addChild(e, 90)
        -- Update wave data (how many remaining)
        waveData[enemyName] = waveData[enemyName] - 1
        -- If the wave is ended, stop generating
        if waveData[enemyName] <= 0 then
            checked[enemyType] = true
            checkCount = checkCount + 1
            if checkCount == #AMPERE.WAVES.names then cclog('Wave ended'); return end
        end
        -- Ready to create next one
        scheduleOnce(parent, createOneEnemy, AMPERE.WAVES.delay[enemyType])
    end
    createOneEnemy()
    
    ---- ==== For debug use only ==== ----
    local t1 = PROPS.create('torch')
    t1:setPosition(posForCharacter(t1, 250))
    props:append(t1)
    scroll:addChild(t1, 80)
    local t2 = PROPS.create('torch')
    t2:setPosition(posForCharacter(t2, 500))
    props:append(t2)
    scroll:addChild(t2, 80)
    local t3 = PROPS.create('torch')
    t3:setPosition(posForCharacter(t3, AMPERE.MAPSIZE / 2 - 300))
    props:append(t3)
    scroll:addChild(t3, 80)
    local t4 = PROPS.create('torch')
    t4:setPosition(posForCharacter(t4, AMPERE.MAPSIZE / 2 + 300))
    props:append(t4)
    scroll:addChild(t4, 80)
end
