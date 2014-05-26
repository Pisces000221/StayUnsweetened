// This need to be compiled to checkif it's right or not.
// Only for Windows use

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "CCScheduler.h"
#include "CCDirector.h"

std::string computerName()
{
	long unsigned n;
	char s[256];
	GetComputerName(s, &n);
	std::string ret(s);
	return ret;
}

int tolua_getComputerName(lua_State *L)
{
    lua_pushstring(L, computerName().c_str()));
    return 1;
}

TOLUA_API int tolua_SchedulerEx_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_function(L, "getComputerName", tolua_getComputerName);
    tolua_endmodule(L);
    return 1;
}

#endif
