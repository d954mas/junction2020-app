// myextension.cpp
// Extension lib defines
#define EXTENSION_NAME debug_game
#define LIB_NAME "debug_game"
#define MODULE_NAME "debug_game"
// include the Defold SDK
#include <dmsdk/sdk.h>
#include "debug_game.h"\

#if defined(DM_PLATFORM_HTML5)

static int LuaDebugGameShowLogs(lua_State* L){
	DebugGameShowLogs(lua_toboolean(L, 1));
    return 0;
}


static const luaL_reg Module_methods[] = {
	{"show_logs",LuaDebugGameShowLogs},
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
