require 'Cocos2d'
require 'src/logging'
require 'src/scenes/MYTEST/MYTEST1'

local function main()
    -- avoid memory leak
    collectgarbage('collect')
    collectgarbage('setpause', 100)
    collectgarbage('setstepmul', 5000)
	cc.FileUtils:getInstance():addSearchResolutionsOrder('src');
	cc.FileUtils:getInstance():addSearchResolutionsOrder('res');
	cc.FileUtils:getInstance():addSearchResolutionsOrder('res/MYTEST');
    
    -- support debugging
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD
      or platform == cc.PLATFORM_OS_ANDROID or platform == cc.PLATFORM_OS_WINDOWS
      or platform == cc.PLATFORM_OS_MAC then
        cclog('DEBUGGING ENABLED')
    else
        cclog('UNABLE TO DEBUG UNDER THIS PLATFORM...')
    end
    
    -- run
    local scene = MYTEST1:create()
	
	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(scene)
	else
		cc.Director:getInstance():runWithScene(scene)
	end
end


xpcall(main, __G__TRACKBACK__)
