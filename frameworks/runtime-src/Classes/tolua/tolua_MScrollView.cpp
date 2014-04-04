extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "LuaBasicConversions.h"

#include "widgets/MScrollView.h"
using namespace M;

int tolua_MScrollView_create(lua_State *L)
{
    M::ScrollView *obj = M::ScrollView::create();
    tolua_pushusertype(L, obj, "MScrollView");
    return 1;
}

int tolua_MScrollView_verticalMode(lua_State *L)
{
    M::ScrollView *obj = (M::ScrollView *)tolua_tousertype(L, 1, NULL);
    if (obj) obj->verticalMode();
    return 1;
}

int tolua_MScrollView_horizonalMode(lua_State *L)
{
    M::ScrollView *obj = (M::ScrollView *)tolua_tousertype(L, 1, NULL);
    if (obj) obj->horizonalMode();
    return 1;
}

int tolua_MScrollView_isHorizonal(lua_State *L)
{
    M::ScrollView *obj = (M::ScrollView *)tolua_tousertype(L, 1, NULL);
    if (obj) {
        bool b = obj->isHorizonal();
        tolua_pushusertype(L, &b, "boolean");
    }
    return 1;
}

//////// overrided methods ////////
int tolua_MScrollView_setContentSize(lua_State *L)
{
    int argc = 0;
    M::ScrollView* cobj = NULL;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(L,1,"cc.Node",0,&tolua_err)) goto tolua_lerror;
#endif
    cobj = (M::ScrollView*)tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(L,"invalid 'cobj' in function 'lua_cocos2dx_Node_setContentSize'", NULL);
        return 0;
    }
#endif
    argc = lua_gettop(L)-1;
    
    if (1 == argc)
    {
        cocos2d::Size size;
        ok &= luaval_to_size(L, 2, &size);
        if (!ok)
            return 0;
        
        cobj->setContentSize(size);
        return 0;
    }
    else if(2 == argc)
    {
        double width;
        ok &= luaval_to_number(L, 2,&width);
        
        if (!ok)
            return 0;
        
        double height;
        ok &= luaval_to_number(L, 3,&height);
        
        if (!ok)
            return 0;
        
        cobj->setContentSize(Size(width, height));
        return 0;
    }
    
    CCLOG("MScrollView: %s has wrong number of arguments: %d, was expecting %d \n", "setContentSize",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'tolua_MScrollView_setContentSize'.",&tolua_err);
#endif
    return 0;
}
//////// ////////

TOLUA_API int tolua_MScrollView_open(lua_State *L)
{
    //http://www.cocos2d-x.org/docs/manual/framework/native/scripting/lua/lua-class-function-manually/zh
    //http://jidangeng.com/2014/03/17/cocos2d-x-3.0rc0-lua-init/
    //http://blog.csdn.net/devday/article/details/5796610
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_usertype(L, "MScrollView");
        tolua_cclass(L, "MScrollView", "MScrollView", "cc.Node", NULL);
        tolua_beginmodule(L, "MScrollView");
            tolua_function(L, "create", tolua_MScrollView_create);
            tolua_function(L, "verticalMode", tolua_MScrollView_verticalMode);
            tolua_function(L, "horizonalMode", tolua_MScrollView_horizonalMode);
            tolua_function(L, "isHorizonal", tolua_MScrollView_isHorizonal);
            
            tolua_function(L, "setContentSize", tolua_MScrollView_setContentSize);
        tolua_endmodule(L);
    tolua_endmodule(L);
    return 1;
}
