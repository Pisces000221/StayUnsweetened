require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'
require 'src/gameplay/crystal_ball'
require 'src/gameplay/waves'
require 'src/data/set'
require 'src/widgets/ScoreLabel'
require 'src/widgets/ScrollZoomer'
require 'src/widgets/SimpleMenuItemSprite'
require 'src/widgets/SunnyMenu'
require 'src/widgets/WaveToast'
require 'src/scenes/PausingScene'

Gameplay = {}
Gameplay.scrollTag = 12138
Gameplay.pauseButtonPadding = cc.p(10, 10)
Gameplay.pauseMenuGetOutDur = 0.6
Gameplay.menuRemoveDelay = Gameplay.pauseMenuGetOutDur
Gameplay.sunnyMoveDur = 0.5
Gameplay.propDropDur = 1
Gameplay.scrollMoveSpeed = 300
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
-- 10 May 2014: WHAT?!!!
-- It's the population of Shanghai, in the maths textbook of Grade 3/4??
-- Why do I still remember this?!!!!
Gameplay.pointerFontSize = 28
Gameplay.pointerOpacity = 192
Gameplay.pointerXPadding = 12
Gameplay.pointerFadeOutDur = 0.3
Gameplay.bonusBubbleMoveDur = 1.4
Gameplay.bonusBubbleFadeDur = 2
Gameplay.bonusGetDur = 1

Gameplay.crystalBallLife = 40
Gameplay.baseScore = 40
Gameplay.baseEnergy = 3 / 8
Gameplay.initialScoreMul = 8
Gameplay.initialEnergy = 30
Gameplay.candyflossInterval = 60

Gameplay.jumpDur = 4
Gameplay.jumpHeight = 100
Gameplay.reacherFadeOutDur = 0.5
Gameplay.reacherJumpCount = 9
Gameplay.reacherYMoveSpeed = 120

Gameplay.constructionOptions =
    { [0] = 'cube', [1] = 'cloud', [2] = 'torch_body', [3] = 'lantern', [4] = 'flood_drop' }
Gameplay.constructionTypes =
    { [1] = 'cloud', [2] = 'torch', [3] = 'lantern', [4] = 'flood' }

local function posForCharacter(ch, x)
    if ch.propPositionY then
        return cc.p(x, StartupScene.groundYOffset + ch:getAnchorPointInPoints().y + ch.propPositionY)
    else return cc.p(x, StartupScene.groundYOffset + ch:getAnchorPointInPoints().y) end
end
local function posYForCharacter(ch, x)
    if ch.propPositionY then
        return StartupScene.groundYOffset + ch:getAnchorPointInPoints().y + ch.propPositionY
    else return StartupScene.groundYOffset + ch:getAnchorPointInPoints().y end
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
    local zoomer
    local enemies = set.new()
    local props = set.new()
    local finished_props = set.new()
    local tickScheduleEntry, cfScheduleEntry = 0, 0
    local tick
    local construct         -- The menu to display construction options
    local scoreLabel, energyLabel, mulLabel
    local enemyPtr = { [1] = { label = nil, arrow = nil }, [2] = { label = nil, arrow = nil } }
    local curWave, waveData, isResting = false
    local pointerVisible = true
    local scoreBall = crystal_ball.new(Gameplay.baseScore, Gameplay.initialScoreMul)
    local energyBall = crystal_ball.new(Gameplay.baseEnergy, Gameplay.initialScoreMul)
    -- Actions used by enemy pointers
    local pointerInAction = cc.FadeTo:create(Gameplay.pointerFadeOutDur, Gameplay.pointerOpacity)
    local pointerOutAction = cc.FadeTo:create(Gameplay.pointerFadeOutDur, 0)
    pointerInAction:retain(); pointerOutAction:retain();
    enableScheduleOnce()
    _G['BALLOON_BONUS'] = 0
    
    local showAllPointers = function() for i = 1, 2 do
        enemyPtr[i].label:runAction(pointerInAction:clone())
        enemyPtr[i].arrow:runAction(pointerInAction:clone())
        pointerVisible = true
    end end
    local hideAllPointers = function() for i = 1, 2 do
        enemyPtr[i].label:runAction(pointerOutAction:clone())
        enemyPtr[i].arrow:runAction(pointerOutAction:clone())
        pointerVisible = false
    end end
    zoomer = ScrollZoomer:create(scroll,
        StartupScene.groundYOffset, hideAllPointers, showAllPointers)
    
    -- Hack: see frameworks/runtime-src/Classes/tolua/tolua_SchedulerEx.cpp
    scroll:setScheduler(newScheduler())
    parent:addChild(zoomer)
    
    local nextWave      -- implement later
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        stopScheduler(scroll:getScheduler())
        zoomer:removeFromParent()
        -- reset display
        hideAllPointers()
        -- Maybe we can use scheduleOnce instead?
        enemyPtr[1].label:runAction(cc.Sequence:create(
            cc.DelayTime:create(pointerOutAction:getDuration()),
            cc.CallFunc:create(function() for i = 1, 2 do
                enemyPtr[i].label:removeFromParent()
                enemyPtr[i].arrow:removeFromParent()
            end end)))
        pointerInAction:release(); pointerOutAction:release()
        pause_item:runAction(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.pauseMenuGetOutDur,
            cc.p(0, pause_item:getContentSize().height + Gameplay.pauseButtonPadding.y)), 0.8))
        menu:runAction(cc.Sequence:create(
            cc.DelayTime:create(Gameplay.menuRemoveDelay),
            cc.RemoveSelf:create()))
        construct:finalize()    -- stop its scheduler
        construct:runAction(cc.Sequence:create(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.sunnyMoveDur, cc.p(0, -SunnyMenu.rayRadius)), 1),
            cc.RemoveSelf:create()))
        local labelAction = cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.scoreLabelMoveDur,
            cc.p(scoreLabel:getContentSize().width, 0)), 0.8)
        scoreLabel:runAction(cc.Sequence:create(labelAction,
            cc.RemoveSelf:create()))
        energyLabel:runAction(cc.Sequence:create(labelAction:clone(),
            cc.RemoveSelf:create()))
        mulLabel:runAction(cc.Sequence:create(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.scoreLabelMoveDur,
            cc.p(0, mulLabel:getContentSize().height + Gameplay.energyLabelYPadding)), 0.8),
            cc.RemoveSelf:create()))
        -- reset data
        while #props > 0 do
            local p = props:pop()
            p:runAction(cc.Sequence:create(
                cc.DelayTime:create(p:destroy()),
                cc.RemoveSelf:create()))
        end
        while #finished_props > 0 do
            local p = finished_props:pop()
            p:runAction(cc.Sequence:create(
                cc.DelayTime:create(p:destroy()),
                cc.RemoveSelf:create()))
        end
        while #enemies > 0 do
            local e = enemies:pop()
            local dx = math.random(size.width / 3) + size.width
            if e.UNIT:position() < AMPERE.MAPSIZE / 2 then dx = -dx end
            e:runAction(cc.Sequence:create(
                cc.MoveBy:create(1, cc.p(dx, 0)),
                cc.RemoveSelf:create()))
        end
        gameOverCallback(scoreBall.score, energyBall.score, _G['BALLOON_BONUS'])
        cclog('Game Over')
    end
    
    local pauseCallback = function()
        local pix, piy = pause_item:getPosition()
        scroll:getScheduler():setTimeScale(0)
        cc.Director:getInstance():pushScene(PausingScene:create(
            pause_item:getAnchorPoint(), cc.p(pix, piy),
            function(choseToRestart)
                if choseToRestart then gameOver()
                else scroll:getScheduler():setTimeScale(1) end
            end))
    end

    pause_item = SimpleMenuItemSprite:create('pause', pauseCallback)
    pause_item:setAnchorPoint(cc.p(0, 1))
    pause_item:setPosition(cc.p(Gameplay.pauseButtonPadding.x,
        size.height - Gameplay.pauseButtonPadding.y))
    pause_item:setOpacity(PausingScene.iconOpacity)
    menu = cc.Menu:create(pause_item)
    menu:setPosition(cc.p(0, 0))
    parent:addChild(menu, 108)
    
    local getBonus = function(value)
        local total_dt = 0
        local entry = 0
        local value_got = 0
        entry = scroll:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt >= Gameplay.bonusGetDur then
                    total_dt = Gameplay.bonusGetDur
                    scroll:getScheduler():unscheduleScriptEntry(entry)
                end
                local cur_value_got = value *
                    math.sin(total_dt / Gameplay.bonusGetDur * 0.5 * math.pi) - value_got
                scoreBall:get_score(cur_value_got * Gameplay.baseScore)
                energyBall:get_score(cur_value_got * Gameplay.baseEnergy)
                value_got = cur_value_got + value_got
            end, 0, false)
    end
    
    -- create enemy warners (enemyPtr)
    for i = 1, 2 do
        enemyPtr[i].label = globalLabel('0', Gameplay.pointerFontSize)
        parent:addChild(enemyPtr[i].label, 177)
        enemyPtr[i].label.isZero = false
        enemyPtr[i].arrow = globalSprite('arrow')
        enemyPtr[i].arrow:setAnchorPoint(cc.p(0, 0))
        enemyPtr[i].arrow:setPosition(cc.p(0, 0))
        enemyPtr[i].arrow:setFlippedX(i == 2)
        parent:addChild(enemyPtr[i].arrow, 177)
    end
    local arrowWidth = globalImageWidth('arrow')
    enemyPtr[1].label:setPosition(cc.p(
        Gameplay.pointerXPadding + arrowWidth, size.height / 2))
    enemyPtr[1].label:setAnchorPoint(cc.p(0, 0.5))
    enemyPtr[1].arrow:setAnchorPoint(cc.p(0, 0.5))
    enemyPtr[1].arrow:setPosition(cc.p(Gameplay.pointerXPadding, size.height / 2))
    enemyPtr[2].label:setPosition(cc.p(
        size.width - Gameplay.pointerXPadding - arrowWidth - 6, size.height / 2))
    enemyPtr[2].label:setAnchorPoint(cc.p(1, 0.5))
    enemyPtr[2].arrow:setAnchorPoint(cc.p(1, 0.5))
    enemyPtr[2].arrow:setPosition(cc.p(size.width - Gameplay.pointerXPadding, size.height / 2))
    local function updatePointers()
        if not pointerVisible then return end
        local P = scroll:getPositionX()
        local LB, RB = -P, size.width - P
        local C = { [1] = 0, [2] = 0 }
        local MIND = { [1] = AMPERE.MAPSIZE, [2] = AMPERE.MAPSIZE }
        local P0, DIR
        for i = 1, #enemies do
            P0 = enemies[i].UNIT:position()
            if P0 < LB then DIR = 1
            elseif P0 > RB then DIR = 2
            else DIR = 0 end
            if DIR ~= 0 then
                C[DIR] = C[DIR] + 1
                local DIST = math.abs(AMPERE.MAPSIZE / 2 - P0)
                if MIND[DIR] > DIST then MIND[DIR] = DIST end
            end
        end
        for i = 1, 2 do if C[i] > 0 then
            enemyPtr[i].label:setString(C[i])
            local R = MIND[i] / (AMPERE.MAPSIZE / 2 + AMPERE.EXTRAMAPSIZE)
            if R >= 0.5 then enemyPtr[i].arrow:setColor(cc.c3b(255, 255, R * 255))
            else enemyPtr[i].arrow:setColor(cc.c3b(255, R * 510, R * 255)) end
            if enemyPtr[i].label.isZero then
                enemyPtr[i].label:runAction(pointerInAction:clone())
                enemyPtr[i].arrow:runAction(pointerInAction:clone())
                enemyPtr[i].label.isZero = false
            end
        elseif not enemyPtr[i].label.isZero then
            enemyPtr[i].label:runAction(pointerOutAction:clone())
            enemyPtr[i].arrow:runAction(pointerOutAction:clone())
            enemyPtr[i].label.isZero = true
        end end
    end
    
    -- give out 30 energy at the beginning
    energyBall:get_score(Gameplay.initialEnergy)
    tick = function(dt)
        -- update enemy warners / pointers
        updatePointers()
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
            if eu.friendly and
             (p > AMPERE.MAPSIZE + AMPERE.EXTRAMAPSIZE
              or p < -AMPERE.EXTRAMAPSIZE) then
                enemies[i]:removeFromParent()
                enemies:remove(i)
            end
            if (eu.isGoingLeft and p < (AMPERE.MAPSIZE + AMPERE.BALLWIDTH) / 2
              or not eu.isGoingLeft and p > (AMPERE.MAPSIZE - AMPERE.BALLWIDTH) / 2)
              and not eu.friendly then
                -- let it jump!
                e:stopAllActions()
                local deltaY = e:getPositionY() - posYForCharacter(e)
                if e.getReacherAction == nil then
                    e:runAction(cc.Sequence:create(
                        cc.MoveBy:create(deltaY / Gameplay.reacherYMoveSpeed, cc.p(0, -deltaY)),
                        cc.JumpBy:create(Gameplay.jumpDur, cc.p(0, 0), Gameplay.jumpHeight, Gameplay.reacherJumpCount),
                        cc.FadeOut:create(Gameplay.reacherFadeOutDur),
                        cc.RemoveSelf:create()))
                else
                    e:runAction(e:getReacherAction())
                end
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
                if enemies[i].destroy ~= nil then enemies[i]:destroy() end
                enemies:remove(i)
                if #enemies == 0 then nextWave(); return; end
                -- debug-use only: display score
                local bub = cc.Label:createWithTTF(globalTTFConfig(36), '+' .. eu.bonus)
                bub:setPosition(cc.p(p, 280))
                scroll:addChild(bub, 1024)
                getBonus(eu.bonus)
                bub:runAction(cc.Sequence:create(cc.Spawn:create(
                    cc.EaseSineOut:create(cc.MoveBy:create(Gameplay.bonusBubbleMoveDur, cc.p(0, 60))),
                    cc.FadeOut:create(Gameplay.bonusBubbleFadeDur)),
                    cc.RemoveSelf:create()))
                i = i - 1
            end
            i = i + 1
        end
        i = 1
        while i <= #props do
            local pu = props[i].UNIT
            pu:update(dt)
            if pu.force[FORCE_HEAT] == 0 and pu.force[FORCE_FLOOD] == 0 then
                if pu.destroyOnFinish then
                    props[i]:destroy()
                else
                    finished_props:append(props[i])
                end
                props:remove(i)
                i = i - 1
            end
            i = i + 1
        end
    end
    -- hello.lua (75)
    tickScheduleEntry = scroll:getScheduler():scheduleScriptFunc(tick, 0, false)
    
    -- Add the construction menu
    construct = SunnyMenu:create(
        Gameplay.constructionOptions,
        function(left, dt)
            if zoomer.zoomed then return end
            local deltaX = dt * Gameplay.scrollMoveSpeed
            if not left then deltaX = -deltaX end
            local px1 = scroll:getPositionX() + deltaX
            if px1 < -AMPERE.MAPSIZE + size.width or px1 > 0 then return end
            scroll:setPositionX(px1)
        end,
        function(idx, p)
            local name = Gameplay.constructionTypes[idx]
            if energyBall.score < PROPS[name].cost then return end
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
            -- POD?
            energyBall:get_score(-PROPS[name].cost)
        end)
    construct:setPosition(cc.p(0, -SunnyMenu.rayRadius))
    construct:runAction(cc.EaseElasticOut:create(
        cc.MoveBy:create(Gameplay.sunnyMoveDur, cc.p(0, SunnyMenu.rayRadius)), 0.6))
    parent:addChild(construct, 99)
    
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
    function scroll.addToEnemy(self, e, p0)
        e:setPosition(posForCharacter(e, p0))
        enemies:append(e)
        self:addChild(e, 90)
    end
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
        scroll:addToEnemy(e, p0)
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

    local createCandyfloss = function()
        local isGoingLeft = math.random(2) == 1
        local cf = SUCROSE.create('candyfloss', isGoingLeft)
        local p0 = -AMPERE.EXTRAMAPSIZE
        if isGoingLeft then p0 = AMPERE.MAPSIZE + AMPERE.EXTRAMAPSIZE end
        scroll:addToEnemy(cf, p0)
    end
    cfScheduleEntry = scroll:getScheduler():scheduleScriptFunc(
        createCandyfloss, Gameplay.candyflossInterval, false)
    createCandyfloss()  -- give one out
    
    nextWave = function()
        if isResting then scheduleImmediately(parent, Gameplay.nextWaveScheduleID); return; end
        cclog('Wave #%d ended, coming in %d seconds', curWave, waveData['rest'])
        local _curWave = curWave
        scheduleOnce(scroll,
            function() createOneEnemy(); WaveToast:show(parent, _curWave + 1) end,
            waveData['rest'], Gameplay.nextWaveScheduleID)
        curWave = curWave + 1
        isResting = true
        scoreBall:inc_multiplier()
        energyBall:inc_multiplier()
        waveData = AMPERE.WAVES.get(curWave)
    end
end
