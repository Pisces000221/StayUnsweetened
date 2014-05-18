require 'Cocos2d'
require 'src/global'
require 'src/widgets/SimpleMenuItemSprite'

AboutScene = {}
AboutScene.scrollHeight = 1200

function AboutScene:create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()

    local bg = cc.LayerGradient:create(
        cc.c4b(192, 255, 192, 255), cc.c4b(192, 255, 216, 255))
    scene:addChild(bg)

    local backButton = SimpleMenuItemSprite:create('restart',
        function() cc.Director:getInstance():popScene() end)
    backButton:setAnchorPoint(cc.p(0, 1))
    backButton:setPosition(cc.p(0, size.height))
    local backSideLen = globalImageWidth('restart')
    local menu = cc.Menu:create(backButton)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu, 30)

    local big = function(label, i)
        label:getLetter(i):setScale(1.3)
        label:getLetter(i):setPositionX(
            label:getLetter(i):getPositionX() + 4)
        for j = i + 1, string.len(label:getString()) - 1 do
            label:getLetter(j):setPositionX(
                label:getLetter(j):getPositionX() + 8)
        end
    end
    local small = function(label, i) label:getLetter(i):setScale(.8) end

    local titleText = 'ABOUT STAYUNSWEETENED'
    local titleLabel = globalLabel(titleText, 68)
    titleLabel:setAnchorPoint(cc.p(0, 1))
    titleLabel:setPosition(cc.p(backSideLen,
        size.height - (backSideLen - titleLabel:getContentSize().height) / 2))
    big(titleLabel, 6); big(titleLabel, 10);
    for i = 0, string.len(titleText) - 1 do
        titleLabel:getLetter(i):setColor(cc.c3b(0, 64, 0))
    end
    scene:addChild(titleLabel, 30)

    local scroll = MScrollView:create()
    scroll:setContentSize(cc.size(size.width, AboutScene.scrollHeight + backSideLen))
    scroll:setPosition(cc.p(0, -(AboutScene.scrollHeight + backSideLen - size.height)))
    scene:addChild(scroll)
    local cover = puritySprite(size.width, backSideLen, cc.c3b(255, 255, 255))
    cover:setAnchorPoint(cc.p(0, 1))
    cover:setPosition(cc.p(0, size.height))
    cover:setOpacity(128)
    scene:addChild(cover, 10)

    local poweredAc = globalLabel('Powered by', 40)
    poweredAc:setAnchorPoint(cc.p(0, 1))
    poweredAc:setPosition(cc.p(0, AboutScene.scrollHeight))
    poweredAc:setColor(cc.c3b(0, 0, 0))
    scroll:addChild(poweredAc)
    local fontName = 'Signika Font'
    local fontAc = globalLabel(fontName, 84, true)
    for i = 0, string.len(fontName) - 1 do small(fontAc, i) end
    fontAc:setAnchorPoint(cc.p(0, 1))
    fontAc:setPosition(cc.p(120, AboutScene.scrollHeight - 50))
    for i = 0, string.len(fontName) - 1 do
        fontAc:getLetter(i):setColor(cc.c3b(64, 64, 64))
    end
    scroll:addChild(fontAc)

    local engineName = 'Cocos2d-x'
    local engineAc = globalLabel(engineName, 76)
    engineAc:setAnchorPoint(cc.p(0.5, 1))
    engineAc:setPosition(cc.p(size.width - 200, AboutScene.scrollHeight - 360))
    engineAc:setColor(cc.c3b(128, 192, 255))
    scroll:addChild(engineAc)
    local engineLogo = cc.Sprite:create('res/cocos2dx_portrait.png')
    engineLogo:setAnchorPoint(cc.p(0.5, 0))
    engineLogo:setScale(0.6)
    engineLogo:setPosition(cc.p(size.width - 200, AboutScene.scrollHeight - 360))
    scroll:addChild(engineLogo)

    local langName = 'The Lua language'
    local langAc = globalLabel(langName, 56)
    langAc:setAnchorPoint(cc.p(0, 0))
    langAc:setPosition(cc.p(0, AboutScene.scrollHeight - 245))
    langAc:setColor(cc.c3b(32, 32, 255))
    scroll:addChild(langAc)
    local langLogo = cc.Sprite:create('res/Lua-Logo_128x128.png')
    langLogo:setAnchorPoint(cc.p(0, 1))
    langLogo:setPosition(cc.p(80, AboutScene.scrollHeight - 225))
    langLogo:setScale(1.25)
    scroll:addChild(langLogo)
    local langLogoDesigner = globalLabel(
        'Graphic design by\nAlexandre Nakonechnyj', 36)
    langLogoDesigner:setAnchorPoint(cc.p(0, 1))
    langLogoDesigner:setPosition(cc.p(0,
        AboutScene.scrollHeight - 245 - langLogo:getContentSize().height))
    langLogoDesigner:setColor(cc.c3b(32, 32, 255))
    scroll:addChild(langLogoDesigner)

    local dragDown = globalLabel('====== Slide up for more... ======', 56)
    dragDown:setAnchorPoint(cc.p(0.5, 0))
    dragDown:setPosition(cc.p(
        size.width / 2, AboutScene.scrollHeight - size.height + 112))
    dragDown:setColor(cc.c3b(128, 128, 128))
    scroll:addChild(dragDown)

    local broughtAc = globalLabel('Brought to you by', 40)
    broughtAc:setAnchorPoint(cc.p(0, 1))
    broughtAc:setPosition(cc.p(0, AboutScene.scrollHeight - size.height + backSideLen))
    broughtAc:setColor(cc.c3b(0, 0, 0))
    scroll:addChild(broughtAc)

    local laFin = globalLabel('Hope you enjoy this game!', 72, true)
    laFin:setAnchorPoint(cc.p(0.5, 0))
    laFin:setPosition(cc.p(size.width / 2, 0))
    laFin:setColor(cc.c3b(128, 128, 128))
    scroll:addChild(laFin)

    return scene
end
