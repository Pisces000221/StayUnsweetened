require 'Cocos2d'
require 'src/global'
require 'src/widgets/BackgroundRepeater'

-- Thanks~
-- http://www.cnblogs.com/linux-ios/archive/2013/04/06/3001946.html

MYTEST3 = {}

function MYTEST3.create()
	local scene = cc.Scene:create()
	local visiblesize = cc.Director:getInstance():getVisibleSize()
	
	local testSprite = globalSprite('chocolate')
	
    --testSprite:setScale(320 / 108)
    testSprite:setOpacity(80)
    scene:addChild(testSprite)

    testSprite:setPosition(cc.p(300, 200))
	
	
	-- Move To Right~
	local movet = cc.MoveBy:create(1, cc.p(200, 0))
	local skewt = cc.SkewTo:create(1, 20, 0)
	local spawnto = cc.Spawn:create(movet, skewt)
	
	local moveb = cc.MoveBy:create(1, cc.p(200, 0))
	local skewb = cc.SkewTo:create(1, 0, 0)
	local spawnback = cc.Spawn:create(moveb, skewb)
	
	local MoveToRight = cc.Sequence:create(spawnto, spawnback)
	
	
	 -- Question:
	 --     Why in cpp, the function is CCSequence::create(..., ..., NULL);
	 --                 but in Lua, the function is cc.Sequence:create(..., ...);
	 --                 Without nil?????
	 --     I tried for about a quarter to find the error in the code.It's the nil!!!

	 
	 -- CCActionInterval * repeatForever =CCRepeatForever::create((CCActionInterval* )seq);
	
	
	
	-- Come back to Left~
	local movet2 = cc.MoveBy:create(1, cc.p(-200, 0))
	local skewt2 = cc.SkewTo:create(1, -20, 0)
	local spawnto2 = cc.Spawn:create(movet2, skewt2)
	
	local moveb2 = cc.MoveBy:create(1, cc.p(-200, 0))
	local skewb2 = cc.SkewTo:create(1, 0, 0)
	local spawnback2 = cc.Spawn:create(moveb2, skewb2)
	
	local BackToLeft = cc.Sequence:create(spawnto2, spawnback2)
	
	-- Together~
	local seq = cc.Sequence:create(MoveToRight, BackToLeft)
	
	-- rpt...
	local _repeat = cc.RepeatForever:create(seq)
	
	-- run
	testSprite:runAction(_repeat)
	
	-- finally
	return scene
end
	