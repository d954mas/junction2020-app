// myextension.cpp
// Extension lib defines
#define EXTENSION_NAME interactive_canvas
#define LIB_NAME "interactive_canvas"
#define MODULE_NAME "interactive_canvas"
// include the Defold SDK
#include <dmsdk/sdk.h>
#include "interactive_canvas.h"

#if defined(DM_PLATFORM_HTML5)

static int LuaInteractiveCanvasInitialize(lua_State* L){
	InteractiveCanvasInitialize();
    return 0;
}
static int LuaInteractiveCanvasSendTextQuery(lua_State* L){
	InteractiveCanvaseSendTextQuery(lua_tostring(L,1));
    return 0;
}
static int LuaInteractiveCanvasExitContinuousMatchMode(lua_State* L){
	InteractiveCanvasExitContinuousMatchMode();
    return 0;
}
static int LuaInteractiveCanvasCanSend(lua_State* L){
	 lua_pushboolean(L, true);
    return 1;
}

static const luaL_reg Module_methods[] = {
	{"init",LuaInteractiveCanvasInitialize},
	{"send_text_query",LuaInteractiveCanvasSendTextQuery},
	{"can_send",LuaInteractiveCanvasCanSend},
	{"exit_continuous_match_mode",LuaInteractiveCanvasExitContinuousMatchMode},
    {0, 0}
};

static void LuaInit(lua_State* L){
	int top = lua_gettop(L);
	luaL_register(L, MODULE_NAME, Module_methods);
	lua_pop(L, 1);
	assert(top == lua_gettop(L));
}


static dmExtension::Result InitializeMyExtension(dmExtension::Params* params) {
    LuaInit(params->m_L);
    printf("Registered %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeMyExtension(dmExtension::Params* params) {
    return dmExtension::RESULT_OK;
}

static dmExtension::Result UpdateMyExtension(dmExtension::Params* params){
    return dmExtension::RESULT_OK;
}

#else

static dmExtension::Result InitializeMyExtension(dmExtension::Params* params) { return dmExtension::RESULT_OK;}
static dmExtension::Result FinalizeMyExtension(dmExtension::Params* params) { return dmExtension::RESULT_OK;}
static dmExtension::Result UpdateMyExtension(dmExtension::Params* params) { return dmExtension::RESULT_OK;}

#endif

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, NULL, NULL, InitializeMyExtension, UpdateMyExtension, 0, FinalizeMyExtension)
