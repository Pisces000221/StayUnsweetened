#ifndef __AMPERE_TOLUA_ALL_H__
#define __AMPERE_TOLUA_ALL_H__

TOLUA_API int tolua_MScrollView_open(lua_State *L);
TOLUA_API int tolua_MoveRotate90_open(lua_State *L);
TOLUA_API int tolua_SchedulerEx_open(lua_State *L);
TOLUA_API int tolua_PuritySprite_open(lua_State *L);
TOLUA_API int tolua_updater_open(lua_State *L);

void tolua_bindAllManual(lua_State *L)
{
    tolua_MScrollView_open(L);
    tolua_MoveRotate90_open(L);
    tolua_SchedulerEx_open(L);
    tolua_PuritySprite_open(L);
    tolua_updater_open(L);
}

#endif
