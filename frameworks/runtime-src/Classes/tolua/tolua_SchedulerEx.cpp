extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "CCScheduler.h"
#include "CCDirector.h"

int tolua_new_Scheduler(lua_State *L)
{
    cocos2d::Scheduler *obj = new cocos2d::Scheduler();
    cocos2d::Director::getInstance()->getScheduler()
        ->scheduleUpdate(obj, 1, false);
    if (obj) {
        toluafix_pushusertype_ccobject(L,
            (int)obj->_ID, &obj->_luaID, (void *)obj, "cc.Scheduler");
    }
    return 1;
}

TOLUA_API int tolua_SchedulerEx_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_function(L, "newScheduler", tolua_new_Scheduler);
    tolua_endmodule(L);
    return 1;
}
