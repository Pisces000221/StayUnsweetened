require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'
require 'src/gameplay/crystal_ball'
require 'src/gameplay/waves'
require 'src/data/set'
require 'src/widgets/ScoreLabel'
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
Gameplay.propDropDur = 1
Gameplay.scoreLabelMoveDur = 1
Gameplay.scoreLabelXPadding = 15
Gameplay.scoreLabelYPadding = 12
Gameplay.energyLabelYPadding = 12
Gameplay.scoreLabelMaxDigits = 12
Gameplay.energyLabelMaxDigits = 6
Gameplay.scoreLabelFontSize = 60
Gameplay.energyLabelFontSize = 45
Gameplay.mulLabelFontSize = 48
Gameplay.mulLabelXPadding = 460
Gameplay.nextWaveScheduleID = 16737700  -- I didn't know what it means... Really.

Gameplay.crystalBallLife = 40
Gameplay.baseScore = 40
Gameplay.baseEnergy = 3 / 8
Gameplay.initialScoreMul = 8

Gameplay.jumpDur = 4
Gameplay.jumpHeight = 100
Gameplay.reacherFadeOutDur = 0.5
Gameplay.reacherJumpCount = 9
Gameplay.reacherYMoveSpeed = 120

Gameplay.constructionOptions =
    { [0] = 'cube', [1] = 'chocolate', [2] = 'torch_body', [3] = 'cane' }
Gameplay.constructionTypes =
    { [1] = 'chocolate', [2] = 'torch', [3] = 'cane' }

local function posForCharacter(ch, x)
    return cc.p(x, Gameplay.groundYOffset + ch:getAnchorPointInPoints().y)
end
local function posYForCharacter(ch, x)
    return Gameplay.groundYOffset + ch:getAnchorPointInPoints().y
end

local isScheduleOnceEnabled = true
local scheduleOnceEntries = {}
local IDs = {}

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

local function scheduleOnce(parent, func, delay, id)
    if not isScheduleOnceEnabled then return end
    local entry = 0
    local removeEntry = function()
        parent:getScheduler():unscheduleScriptEntry(entry)
        for i = 1, #scheduleOnceEntries do
            if scheduleOnceEntries[i] == entry then
                scheduleOnceEntries[i] = nil
                break
            end
        end
    end
    entry = parent:getScheduler():scheduleScriptFunc(
        function() removeEntry(); func() end, delay, false)
    scheduleOnceEntries[#scheduleOnceEntries + 1] = entry
    if id ~= nil then IDs[id] = { ENTRY = entry, CALLBACK = func } end
end

local function scheduleImmediately(parent, id)
    if not isScheduleOnceEnabled then return end
    local entry = IDs[id].ENTRY
    -- remove entry and unschedule
    parent:getScheduler():unscheduleScriptEntry(entry)
    for i = 1, #scheduleOnceEntries do
        if scheduleOnceEntries[i] == entry then
            scheduleOnceEntries[i] = nil
            break
        end
    end
    IDs[id].CALLBACK()
    IDs[id] = nil
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
    local scoreLabel, energyLabel, mulLabel
    local curWave, waveData, isResting = false
    local scoreBall = crystal_ball.new(Gameplay.baseScore, Gameplay.initialScoreMul)
    local energyBall = crystal_ball.new(Gameplay.baseEnergy, Gameplay.initialScoreMul)
    enableScheduleOnce()
    
    -- Hack: see frameworks/runtime-src/Classes/tolua/tolua_SchedulerEx.cpp
    scroll:setScheduler(newScheduler())
    
    local nextWave      -- implement later
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        scroll:getScheduler():unscheduleScriptEntry(tickScheduleEntry)
        stopAllScheduleOnce(scroll)
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
        local labelAction = cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.scoreLabelMoveDur,
            cc.p(scoreLabel:getContentSize().width, 0)), 0.8)
        scoreLabel:runAction(cc.Sequence:create(labelAction,
            cc.CallFunc:create(function() scoreLabel:removeFromParent() end)))
        energyLabel:runAction(cc.Sequence:create(labelAction:clone(),
            cc.CallFunc:create(function() energyLabel:removeFromParent() end)))
        mulLabel:runAction(cc.Sequence:create(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.scoreLabelMoveDur,
            cc.p(0, mulLabel:getContentSize().height + Gameplay.energyLabelYPadding)), 0.8),
            cc.CallFunc:create(function() mulLabel:removeFromParent() end)))
        -- reset data
        while #props > 0 do
            local p = props:pop()
            p:runAction(cc.Sequence:create(
                cc.DelayTime:create(p:destroy()),
                cc.CallFunc:create(function() p:removeFromParent() end)))
        end
        while #enemies > 0 do
            local e = enemies:pop()
            local dx = math.random(size.width / 3) + size.width
            if e.UNIT:position() < AMPERE.MAPSIZE / 2 then dx = -dx end
            e:runAction(cc.Sequence:create(
                cc.MoveBy:create(1, cc.p(dx, 0)),
                cc.CallFunc:create(function() e:removeFromParent() end)))
        end
        gameOverCallback()
        cclog('Game Over')
    end
    
    local pauseCallback = function()
        local pix, piy = pause_item:getPosition()
        scroll:getScheduler():setTimeScale(0)
        cc.Director:getInstance():pushScene(PausingScene:create(
            pause_item:getAnchorPoint(), cc.p(pix, piy),
            function(choseToRestart)
                scroll:getScheduler():setTimeScale(1)
                if choseToRestart then gameOver()
                else tickScheduleEntry = scroll:getScheduler():scheduleScriptFunc(tick, 0, false) end
            end))
        scroll:getScheduler():unscheduleScriptEntry(tickScheduleEntry)
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
        -- update score
        scoreBall:update(dt)
        energyBall:update(dt)
        scoreLabel:setNumber(scoreBall.score)
        energyLabel:setNumber(energyBall.score)
        -- update everybody on the screen
        local i = 1
        while i <= #enemies do
            local p = enemies[i].UNIT:position()
            local eu = enemies[i].UNIT
            local e = enemies[i]
            if eu.isGoingLeft and p < (AMPERE.MAPSIZE + AMPERE.BALLWIDTH) / 2
              or not eu.isGoingLeft and p > (AMPERE.MAPSIZE - AMPERE.BALLWIDTH) / 2 then
                -- let it jump!
                e:stopAllActions()
                local deltaY = e:getPositionY() - posYForCharacter(e)
                e:runAction(cc.Sequence:create(
                    cc.MoveBy:create(deltaY / Gameplay.reacherYMoveSpeed, cc.p(0, -deltaY)),
                    cc.JumpBy:create(Gameplay.jumpDur, cc.p(0, 0), Gameplay.jumpHeight, Gameplay.reacherJumpCount),
                    cc.FadeOut:create(Gameplay.reacherFadeOutDur),
                    cc.CallFunc:create(function() e:removeFromParent() end)))
                print('reacher isgoingleft: ', enemies[i].UNIT.isGoingLeft)
                print('reacher position: ', p)
                scoreBall:dec_base_score(1 / Gameplay.crystalBallLife)
                energyBall:dec_base_score(1 / Gameplay.crystalBallLife)
                mulLabel:setString('x' .. scoreBall:base_score_rate() * Gameplay.crystalBallLife)
                -- Timber!!
                enemies:remove(i)
                if #enemies == 0 then nextWave(); return; end
                if scoreBall:is_finished() then gameOver(); return; end
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
                if #enemies == 0 then nextWave(); return; end
                -- debug-use only: display score
                local bub = cc.Label:createWithTTF(globalTTFConfig(36), eu.name)
                bub:setPosition(cc.p(p, 280))
                scroll:addChild(bub, 1024)
                bub:runAction(cc.Sequence:create(cc.Spawn:create(
                    cc.EaseSineOut:create(cc.MoveBy:create(1.4, cc.p(0, 60))),
                    cc.FadeOut:create(2)),
                    cc.CallFunc:create(function() bub:removeFromParent() end)))
                i = i - 1
            end
            i = i + 1
        end
        for i = 1, #props do props[i].UNIT:update(dt) end
    end
    -- hello.lua (75)
    tickScheduleEntry = scroll:getScheduler():scheduleScriptFunc(tick, 0, false)
    
    -- Add the construction menu
    construct = SunnyMenu:create(
        Gameplay.constructionOptions,
        function(idx, p)
            local name = Gameplay.constructionTypes[idx]
            local ch = PROPS.create(name)
            local p0 = -scroll:getPosition()    -- will only get X here
            local anchor = ch:getAnchorPoint()
            local sch = ch:getTextureRect()
            anchor.x = (anchor.x - 0.5) * sch.width
            anchor.y = (anchor.y - 0.5) * sch.height
            -- Now anchor is in points
            ch:setPosition(cc.p(p0 + p.x + anchor.x, p.y + anchor.y))
            ch:runAction(cc.EaseQuadraticActionOut:create(
                cc.MoveTo:create(Gameplay.propDropDur, posForCharacter(ch, p0 + p.x + anchor.x))))
            props:append(ch)
            scroll:addChild(ch, 80)
        end)
    construct:setPosition(cc.p(0, -SunnyMenu.rayRadius))
    construct:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(Gameplay.sunnyMoveDur, cc.p(0, SunnyMenu.rayRadius)), 0.6))
    parent:addChild(construct)
    
    -- Display score
    scoreLabel = ScoreLabel:create(Gameplay.scoreLabelFontSize, Gameplay.scoreLabelMaxDigits)
    scoreLabel:setAnchorPoint(cc.p(1, 1))
    scoreLabel:setPosition(cc.p(
        size.width + scoreLabel:getContentSize().width - Gameplay.scoreLabelXPadding,
        size.height - Gameplay.scoreLabelYPadding))
    parent:addChild(scoreLabel)
    scoreLabel:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(Gameplay.scoreLabelMoveDur, cc.p(-scoreLabel:getContentSize().width, 0)), 0.8))
    -- Display energy
    energyLabel = ScoreLabel:create(Gameplay.energyLabelFontSize, Gameplay.energyLabelMaxDigits)
    energyLabel:setAnchorPoint(cc.p(1, 1))
    energyLabel:setPosition(cc.p(
        size.width + energyLabel:getContentSize().width - Gameplay.scoreLabelXPadding,
        size.height - Gameplay.energyLabelYPadding - scoreLabel:getContentSize().height))
    parent:addChild(energyLabel)
    energyLabel:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(Gameplay.scoreLabelMoveDur, cc.p(-energyLabel:getContentSize().width, 0)), 0.8))
    -- Display multiplier
    mulLabel = globalLabel('x' .. Gameplay.crystalBallLife, Gameplay.mulLabelFontSize)
    mulLabel:setAnchorPoint(cc.p(1, 0))
    mulLabel:setPosition(cc.p(
        size.width - Gameplay.mulLabelXPadding,
        size.height - Gameplay.scoreLabelYPadding))
    parent:addChild(mulLabel)
    mulLabel:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(Gameplay.scoreLabelMoveDur, cc.p(0, -mulLabel:getContentSize().height)), 0.8))
    
    curWave = 1
    WaveToast:show(parent, curWave)
    waveData = AMPERE.WAVES.get(curWave)
    local function createOneEnemy()
        isResting = false
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
            if checkCount == #AMPERE.WAVES.names then
                nextWave()
                return
            end
        end
        -- Ready to create next one
        scheduleOnce(scroll, createOneEnemy, AMPERE.WAVES.delay[enemyType])
    end
    createOneEnemy()
    
    nextWave = function()
        if isResting then scheduleImmediately(parent, Gameplay.nextWaveScheduleID); return; end
        cclog('Wave #%d ended, coming in %d seconds', curWave, waveData['rest'])
        scheduleOnce(scroll,
            function() createOneEnemy(); WaveToast:show(parent, curWave) end,
            waveData['rest'], Gameplay.nextWaveScheduleID)
        curWave = curWave + 1
        isResting = true
        scoreBall:inc_multiplier()
        energyBall:inc_multiplier()
        waveData = AMPERE.WAVES.get(curWave)
    end
end
