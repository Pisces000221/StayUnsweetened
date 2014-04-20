require 'Cocos2d'
require 'src/global'
require 'src/gameplay/all_characters'
require 'src/gameplay/waves'
require 'src/data/set'
require 'src/widgets/SimpleMenuItemSprite'
require 'src/widgets/WaveToast'
require 'src/scenes/PausingScene'

Gameplay = {}
Gameplay.scrollTag = 12138
Gameplay.groundYOffset = 80
Gameplay.pauseButtonPadding = cc.p(10, 10)
Gameplay.pauseMenuGetOutDur = 0.6
Gameplay.menuRemoveDelay = Gameplay.pauseMenuGetOutDur

Gameplay.jumpDur = 4
Gameplay.jumpHeight = 100
Gameplay.reacherFadeOutDur = 0.5
Gameplay.reacherJumpCount = 9
Gameplay.reacherYMoveSpeed = 120

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
    local tickScheduleEntry = 0
    enableScheduleOnce()
    -- We have to implement this here
    -- 'Cause if not, our lovely registerScriptTapHandler will raise an error.
    local gameOver = function()
        parent:getScheduler():unscheduleScriptEntry(tickScheduleEntry)
        stopAllScheduleOnce(parent)
        pause_item:runAction(cc.EaseElasticIn:create(
            cc.MoveBy:create(Gameplay.pauseMenuGetOutDur,
            cc.p(0, pause_item:getContentSize().height + Gameplay.pauseButtonPadding.y)), 0.8))
        menu:runAction(cc.Sequence:create(
            cc.DelayTime:create(Gameplay.menuRemoveDelay),
            cc.CallFunc:create(function() menu:removeFromParent() end)))
        while #enemies > 0 do
            local e = enemies:pop()
            if e.UNIT.reachedBall then
                e:stopAllActions()
                local deltaY = e:getPositionY()
                    - e:getAnchorPointInPoints().y - Gameplay.groundYOffset
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
            function(choseToRestart) if choseToRestart then gameOver() end end))
    end

    local back_item = cc.MenuItemLabel:create(
        cc.Label:createWithTTF(globalTTFConfig(30), 'GO BACK'))
    back_item:registerScriptTapHandler(gameOver)
    back_item:setPosition(cc.p(200, 200))
    pause_item = SimpleMenuItemSprite:create('pause', pauseCallback)
    pause_item:setAnchorPoint(cc.p(0, 1))
    pause_item:setPosition(cc.p(Gameplay.pauseButtonPadding.x,
        size.height - Gameplay.pauseButtonPadding.y))
    pause_item:setOpacity(PausingScene.iconOpacity)
    menu = cc.Menu:create(back_item, pause_item)
    menu:setPosition(cc.p(0, 0))
    parent:addChild(menu)
    
    local tick = function()
        for i = 1, #enemies do
            local p = enemies[i].UNIT:position()
            if enemies[i].UNIT.isGoingLeft and p < (AMPERE.MAPSIZE + AMPERE.BALLWIDTH) / 2
              or  not enemies[i].UNIT.isGoingLeft and p > (AMPERE.MAPSIZE - AMPERE.BALLWIDTH) / 2 then
                enemies[i].UNIT.reachedBall = true
                print('reacher isgoingleft: ', enemies[i].UNIT.isGoingLeft)
                print('reacher position: ', p)
                gameOver()
            end
        end
    end
    -- hello.lua (75)
    tickScheduleEntry = parent:getScheduler():scheduleScriptFunc(tick, 0, false)
    
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
        e:setPosition(cc.p(p0, Gameplay.groundYOffset + e:getAnchorPointInPoints().y))
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
end
