extern "C" {
#include "tolua++.h"
}
#include "LuaBasicConversions.h"
#include "tolua_fix.h"
#include "cocos2d.h"
using namespace cocos2d;

Sprite *puritySprite(int width, int height, Color3B colour)
{
    CCLOG("puritySprite %d x %d @ (%d, %d, %d)", width, height, colour.r, colour.g, colour.b);
    int colour_num = (colour.b << 16) + (colour.g << 8) + colour.r;
    //int *a = new int [width * height];
    //memset(a, colour_num, width * height);
    Texture2D *texture = new Texture2D();
    //texture->initWithData(a, width * height,
    //    Texture2D::PixelFormat::RGB888, width, height, Size(width, height));
    texture->initWithData(&colour_num, 1, Texture2D::PixelFormat::RGB888, 1, 1, Size(1, 1));
    Sprite *sprite = Sprite::createWithTexture(texture);
    sprite->setScaleX(width);
    sprite->setScaleY(height);
    return sprite;
}

int tolua_purity_Sprite(lua_State *L)
{
    int argc = lua_gettop(L);
    bool ok = true;
    if (argc == 3) {
        double width, height;
        Color3B colour;
        ok &= luaval_to_number(L, 1, &width);
        ok &= luaval_to_number(L, 2, &height);
        ok &= luaval_to_color3b(L, 3, &colour);
        if (!ok) {
            CCLOG("puritySprite: invalid parameters");
            return 0;
        }
        Sprite *obj = puritySprite((int)width, (int)height, colour);
        if (obj) {
            toluafix_pushusertype_ccobject(L,
                (int)obj->_ID, &obj->_luaID, (void *)obj, "cc.Sprite");
        } else CCLOG("puritySprite: create sprite failed");
    } else {
        CCLOG("puritySprite: invalid parameters (got %d)", argc);
    }
    return 1;
}

TOLUA_API int tolua_PuritySprite_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_function(L, "puritySprite", tolua_purity_Sprite);
    tolua_endmodule(L);
    return 1;
}
