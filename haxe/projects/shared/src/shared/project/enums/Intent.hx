package shared.project.enums;


import shared.project.model.World;
import shared.base.enums.ContextName;

@:expose @:keep
enum abstract Intent(String) {
    var MAIN_WELCOME = "main.welcome";
    var MAIN_FALLBACK = "main.fallback";
    var MAIN_ERROR = "main.error";
    var MAIN_KEEP_WORKING = "main.keep_working"; //every 3m to keep action online
    var WEBAPP_LOAD_DONE = "webapp.load_done";
    var IAP_BUY = "actions.iap.buy";

    var CHEATS_ENABLE = "cheats.enable";
    var CHEATS_DISABLE = "cheats.disable";

    var DEBUG_TOGGLE = "debug.toggle";

    var TUTORIAL_YES = "tutorial.yes";
    var TUTORIAL_NO = "tutorial.no";

}

typedef ModalCloseIntent = {
var context:ContextName;
var intent:Intent;
};


@:expose @:keep class Intents {
    public static var intentContexts:Map<Intent, Array<ContextName>> = new Map();
    public static var ignoreTutorialCheck:Map<Intent, Bool> = new Map();
    public static var modalContexts:Map<ContextName, Bool> = new Map();
    public static var commandCloseOrder:Array<ModalCloseIntent> = new Array();


    public static function init() {
        intentContexts = new Map();
        intentContexts[Intent.MAIN_WELCOME] = [];
        intentContexts[Intent.MAIN_FALLBACK] = [];
        intentContexts[Intent.MAIN_ERROR] = [];
        intentContexts[Intent.MAIN_KEEP_WORKING] = [];

        intentContexts[Intent.WEBAPP_LOAD_DONE] = [];
        intentContexts[Intent.IAP_BUY] = [];


        intentContexts[Intent.CHEATS_ENABLE] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_DISABLE] = [ContextName.DEV];
        intentContexts[Intent.DEBUG_TOGGLE] = [ContextName.DEV];


        intentContexts[Intent.TUTORIAL_NO] = [];
        intentContexts[Intent.TUTORIAL_YES] = [];



        ignoreTutorialCheck.set(Intent.MAIN_WELCOME, true);
        ignoreTutorialCheck.set(Intent.DEBUG_TOGGLE, true);
        ignoreTutorialCheck.set(Intent.CHEATS_DISABLE, true);
        ignoreTutorialCheck.set(Intent.CHEATS_ENABLE, true);
        ignoreTutorialCheck.set(Intent.WEBAPP_LOAD_DONE, true);
        ignoreTutorialCheck.set(Intent.MAIN_FALLBACK, true);
        ignoreTutorialCheck.set(Intent.MAIN_ERROR, true);
        ignoreTutorialCheck.set(Intent.MAIN_KEEP_WORKING, true);
        ignoreTutorialCheck.set(Intent.IAP_BUY, true);
        ignoreTutorialCheck.set(Intent.TUTORIAL_YES, true);


    }


    public static function isIntent(name:Intent) {
        return intentContexts.exists(name);
    }

    public static function contextIsModal(ctx:ContextName) {
        return modalContexts.exists(ctx);
    }

    public static function worldHaveModalContext(world:World) {
        for (ctx in world.contextGetAll()) {
            if (contextIsModal(ctx.name)) {
                return true;
            }
        }
        return false;
    }


}