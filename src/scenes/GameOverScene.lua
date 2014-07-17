require 'Cocos2d'
require 'src/global'
require 'src/data_save'
require 'src/widgets/ScoreLabel'
require 'src/scenes/Gameplay'

GameOverScene = {}
GameOverScene.backgroundTintDur = 0.5
GameOverScene.backgroundTintWhite = 96
GameOverScene.actionInterval = 0.3
GameOverScene.numberExhangeDelay = 1.1
GameOverScene.energyConvertSpeed = 100
GameOverScene.balloonConvertDur = 1
GameOverScene.hiscoreCatchUpDur = 1

GameOverScene.energyConvertRate = 160

GameOverScene.tagsToRemoveOnClose = { 1238764, 233333 }

function GameOverScene.create(self, score, energy, balloon)
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    local energyConvertDur = energy / GameOverScene.energyConvertSpeed
    local convertEnergyEntry, convertBalloonEntry, hiscoreCatchUpEntry = 0, 0, 0
    local score_t0 = score
    local score_t1 = score_t0 + energy * GameOverScene.energyConvertRate
    local score_t2 = score_t1 * (1 + balloon / 100)
    local score_final = score_t2
    cclog('score = %d', score_final)
    local energy2score, balloon2score, show_hiscore

    -- display background
    local texture = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    texture:beginWithClear(0, 0, 0, 0)
    cc.Director:getInstance():getRunningScene():visit()
    texture:endToLua()
    local bgSprite = texture:getSprite()
    bgSprite:removeFromParent()
    bgSprite:setAnchorPoint(cc.p(0, 0))
    bgSprite:setPosition(cc.p(0, 0))
    bgSprite:setFlippedY(true)
    scene:addChild(texture:getSprite())
    bgSprite:runAction(cc.Sequence:create(cc.TintTo:create(
        GameOverScene.backgroundTintDur, GameOverScene.backgroundTintWhite,
        GameOverScene.backgroundTintWhite, GameOverScene.backgroundTintWhite),
        cc.CallFunc:create(function() energy2score() end)))

    local score_t = globalLabel('Score: ', 68, true)
    score_t:setAnchorPoint(cc.p(0, 0.5))
    score_t:setPosition(cc.p(24, size.height * 0.7))
    score_t:setOpacity(0)
    score_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur),
        cc.FadeIn:create(GameOverScene.actionInterval)))
    scene:addChild(score_t)
    local score_s = ScoreLabel:create(84, Gameplay.scoreLabelMaxDigits)
    score_s:setNumber(score_t0)
    score_s:setAnchorPoint(cc.p(1, 0.5))
    score_s:setPosition(cc.p(size.width - 36, size.height * 0.7))
    score_s:setVisible(false)
    score_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 2),
        cc.Show:create()))
    scene:addChild(score_s)

    local energy_t = globalLabel('Energy: ', 68, true)
    energy_t:setAnchorPoint(cc.p(0, 0.5))
    energy_t:setPosition(cc.p(24, size.height * 0.4))
    energy_t:setOpacity(0)
    energy_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 3),
        cc.FadeIn:create(GameOverScene.actionInterval),
        cc.DelayTime:create(energyConvertDur + GameOverScene.actionInterval + 0.8),
        cc.FadeOut:create(GameOverScene.actionInterval)))
    scene:addChild(energy_t)
    local energy_s = ScoreLabel:create(84, Gameplay.energyLabelMaxDigits)
    energy_s:setNumber(energy)
    energy_s:setAnchorPoint(cc.p(1, 0.5))
    energy_s:setPosition(cc.p(size.width - 36, size.height * 0.4))
    energy_s:setVisible(false)
    energy_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 5),
        cc.Show:create(),
        cc.DelayTime:create(energyConvertDur + GameOverScene.actionInterval + 0.8),
        cc.Hide:create()))
    scene:addChild(energy_s)

    energy2score = function()
        local total_dt = -GameOverScene.actionInterval * 6
        convertEnergyEntry = scene:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt < 0 then return end
                if total_dt >= energyConvertDur then
                    total_dt = energyConvertDur
                    scene:getScheduler():unscheduleScriptEntry(convertEnergyEntry)
                    score_s:setNumber(score_t1)
                    energy_s:setNumber(0)
                    balloon2score()
                    return
                end
                score_s:setNumber((score_t1 - score_t0) * (total_dt / energyConvertDur) + score_t0)
                energy_s:setNumber((1 - total_dt / energyConvertDur) * energy)
            end, 0, false)
    end

    local balloon_t = globalLabel('Balloon: ', 68, true)
    balloon_t:setAnchorPoint(cc.p(0, 0.5))
    balloon_t:setPosition(cc.p(24, size.height * 0.4))
    balloon_t:setOpacity(0)
    balloon_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 5 + 0.8),
        cc.FadeIn:create(GameOverScene.actionInterval),
        cc.DelayTime:create(GameOverScene.balloonConvertDur + 1.6),
        cc.FadeOut:create(GameOverScene.actionInterval)))
    scene:addChild(balloon_t)
    local balloon_s = globalLabel('+ ' .. balloon .. '%', 84)
    balloon_s:setAnchorPoint(cc.p(1, 0.5))
    balloon_s:setPosition(cc.p(size.width - 36, size.height * 0.4))
    balloon_s:setVisible(false)
    balloon_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 7 + 0.8),
        cc.Show:create(),
        cc.DelayTime:create(GameOverScene.balloonConvertDur + 1.6),
        cc.Hide:create()))
    scene:addChild(balloon_s)

    balloon2score = function()
        local total_dt = -(GameOverScene.numberExhangeDelay + GameOverScene.actionInterval * 2)
        convertBalloonEntry = scene:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt < 0 then return end
                if total_dt >= GameOverScene.balloonConvertDur then
                    total_dt = GameOverScene.balloonConvertDur
                    scene:getScheduler():unscheduleScriptEntry(convertBalloonEntry)
                    score_s:setNumber(score_t2)
                    balloon_s:setString('+ 0%')
                    show_hiscore()
                    return
                end
                score_s:setNumber(score_t1 * (1 + total_dt / GameOverScene.balloonConvertDur * balloon / 100))
                balloon_s:setString(string.format('+ %d%%',
                    (1 - total_dt / GameOverScene.balloonConvertDur) * balloon))
            end, 0, false)
    end

    -- Load high score
    local hiscore = data_save.getHighScore()
    local hiscore_t = globalLabel('Best: ', 68, true)
    hiscore_t:setAnchorPoint(cc.p(0, 0.5))
    hiscore_t:setPosition(cc.p(24, size.height * 0.4))
    hiscore_t:setOpacity(0)
    hiscore_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur + GameOverScene.balloonConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 9 + 1.6),
        cc.FadeIn:create(GameOverScene.actionInterval)))
    scene:addChild(hiscore_t)
    local hiscore_s = ScoreLabel:create(84, Gameplay.scoreLabelMaxDigits)
    hiscore_s:setNumber(hiscore)
    hiscore_s:setAnchorPoint(cc.p(1, 0.5))
    hiscore_s:setPosition(cc.p(size.width - 36, size.height * 0.4))
    hiscore_s:setVisible(false)
    hiscore_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur + GameOverScene.balloonConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 11 + 1.6),
        cc.Show:create()))
    scene:addChild(hiscore_s)

    show_hiscore = function()
        local total_dt = -(GameOverScene.numberExhangeDelay + GameOverScene.actionInterval * 4)
        hiscoreCatchUpEntry = scene:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt < 0 then return end
                --if hiscore >= score_final then scene:getScheduler():unscheduleScriptEntry(hiscoreCatchUpEntry); return end
                if total_dt >= GameOverScene.hiscoreCatchUpDur then
                    total_dt = GameOverScene.hiscoreCatchUpDur
                    scene:getScheduler():unscheduleScriptEntry(hiscoreCatchUpEntry)
                    data_save.setHighScore(score_final)
                    -- Run 'new record' animation
                    local cheers = cc.ParticleFireworks:create()
                    cheers:setPosition(cc.p(size.width / 2, 0))
                    cheers:setScale(3)
                    cheers.out_type = 'scale'
                    scene:addChild(cheers, 100, GameOverScene.tagsToRemoveOnClose[1])
                    local new_rec_label = globalLabel('New record!!', 48, true)
                    new_rec_label:setAnchorPoint(cc.p(1, 0.1))
                    new_rec_label:setPosition(hiscore_s:getPosition())
                    new_rec_label:setRotation(10)
                    new_rec_label:setColor(cc.c3b(255, 128, 0))
                    new_rec_label:setScale(0)
                    new_rec_label.out_type = 'fade'
                    scene:addChild(new_rec_label, 99, GameOverScene.tagsToRemoveOnClose[2])
                    new_rec_label:runAction(cc.EaseElasticOut:create(
                        cc.ScaleTo:create(1, 1), 1.5))
                end
                hiscore_s:setNumber((score_t2 - hiscore) * total_dt / GameOverScene.hiscoreCatchUpDur + hiscore)
            end, 0, false)
    end

    local close = function()
        score_s:runAction(cc.Hide:create())
        score_t:runAction(cc.FadeOut:create(0.4))
        hiscore_s:runAction(cc.Hide:create())
        hiscore_t:runAction(cc.FadeOut:create(0.4))
        for i = 1, #GameOverScene.tagsToRemoveOnClose do
            local a = scene:getChildByTag(GameOverScene.tagsToRemoveOnClose[i])
            if a and a.out_type == 'fade' then
                a:runAction(cc.FadeOut:create(0.4))
            elseif a and a.out_type == 'scale' then
                a:runAction(cc.ScaleTo:create(0.2, 0))
            end
        end
        bgSprite:runAction(cc.TintTo:create(
            GameOverScene.backgroundTintDur, 255, 255, 255))
        scene:runAction(cc.Sequence:create(
            cc.DelayTime:create(GameOverScene.backgroundTintDur),
            cc.CallFunc:create(function()
                cc.Director:getInstance():popScene() end)))
        scene:getScheduler():unscheduleScriptEntry(convertEnergyEntry)
        scene:getScheduler():unscheduleScriptEntry(convertBalloonEntry)
        scene:getScheduler():unscheduleScriptEntry(hiscoreCatchUpEntry)
    end

    local close_item = cc.MenuItemLabel:create(globalLabel('Close', 55))
    close_item:registerScriptTapHandler(close)
    close_item:setPosition(cc.p(size.width / 2, size.height * 0.18))
    local menu = cc.Menu:create(close_item)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu)

    return scene
end
