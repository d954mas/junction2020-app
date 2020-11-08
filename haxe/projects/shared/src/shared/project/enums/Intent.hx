package shared.project.enums;


import shared.project.model.World;
import shared.base.enums.ContextName;

@:expose @:keep
enum abstract Intent(String) {
    var MAIN_WELCOME = "main.welcome";
    var MAIN_FALLBACK = "main.fallback";
    var MAIN_ERROR = "main.error";
    var MAIN_KEEP_WORKING = "main.keep_working"; //every 3m to keep action online
    var MAIN_HELP = "main.help";

    var WEBAPP_LOAD_DONE = "webapp.load_done";
    var IAP_BUY = "actions.iap.buy";

    var CHEATS_ENABLE = "cheats.enable";
    var CHEATS_DISABLE = "cheats.disable";
    var CHEATS_MONEY_ADD = "cheats.money.add";
    var CHEATS_MANA_ADD = "cheats.mana.add";
    var CHEATS_RESTORE_HP = "cheats.restore_hp";
    var CHEATS_KILL_ALL_ENEMIES = "cheats.kill_all_enemies";

    var DEBUG_TOGGLE = "debug.toggle";

    var TUTORIAL_YES = "tutorial.yes";
    var TUTORIAL_NO = "tutorial.no";

    var LEVEL_SPAWN_UNIT = "level.spawn.unit";
    var LEVEL_CAST = "level.cast";
    var LEVEL_TURN_SKIP = "level.turn.skip";
    var LEVEL_SPAWN_CARAVAN = "level.spawn.caravan";



    var SIMPLE_UNIT_KNIGHT = "simple.unit.knight";
    var SIMPLE_UNIT_ARCHER = "simple.unit.archer";
    var SIMPLE_UNIT_SPEARMAN = "simple.unit.spearman";
    var SIMPLE_UNIT_TANK = "simple.unit.tank";
    var SIMPLE_UNIT_MAGE = "simple.unit.mage";

    var SIMPLE_SPELL_FIREBALL = "simple.spell.fireball";
    var SIMPLE_SPELL_ICE= "simple.spell.ice";
    var SIMPLE_SPELL_UPGRADE_MANA = "simple.spell.upgrade_mana";
    var SIMPLE_SPELL_UPGRADE_CARAVAN = "simple.spell.upgrade_caravan";

    var LOSE_MODAL_RESTART = "lose.modal.restart";
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
        intentContexts[Intent.MAIN_HELP] = [];

        intentContexts[Intent.WEBAPP_LOAD_DONE] = [];
        intentContexts[Intent.IAP_BUY] = [];

        intentContexts[Intent.LEVEL_CAST] = [];
        intentContexts[Intent.LEVEL_SPAWN_UNIT] = [];
        intentContexts[Intent.LEVEL_TURN_SKIP] = [];

        intentContexts[Intent.LOSE_MODAL_RESTART] = [ContextName.LOSE_MODAL];

        intentContexts[Intent.DEBUG_TOGGLE] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_ENABLE] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_DISABLE] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_MANA_ADD] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_MONEY_ADD] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_KILL_ALL_ENEMIES] = [ContextName.DEV];
        intentContexts[Intent.CHEATS_RESTORE_HP] = [ContextName.DEV];


        intentContexts[Intent.TUTORIAL_NO] = [];
        intentContexts[Intent.TUTORIAL_YES] = [];
        intentContexts[Intent.LEVEL_SPAWN_CARAVAN] = [];

        intentContexts[Intent.SIMPLE_UNIT_ARCHER] = [];
        intentContexts[Intent.SIMPLE_UNIT_KNIGHT] = [];
        intentContexts[Intent.SIMPLE_UNIT_MAGE] = [];
        intentContexts[Intent.SIMPLE_UNIT_SPEARMAN] = [];
        intentContexts[Intent.SIMPLE_UNIT_TANK] = [];

        intentContexts[Intent.SIMPLE_SPELL_FIREBALL] = [];
        intentContexts[Intent.SIMPLE_SPELL_ICE] = [];
        intentContexts[Intent.SIMPLE_SPELL_UPGRADE_MANA] = [];
        intentContexts[Intent.SIMPLE_SPELL_UPGRADE_CARAVAN] = [];


        ignoreTutorialCheck.set(Intent.MAIN_WELCOME, true);
        ignoreTutorialCheck.set(Intent.LOSE_MODAL_RESTART, true);
        ignoreTutorialCheck.set(Intent.LEVEL_SPAWN_UNIT, true);
        ignoreTutorialCheck.set(Intent.LEVEL_CAST, true);
        ignoreTutorialCheck.set(Intent.LEVEL_TURN_SKIP, true);
        ignoreTutorialCheck.set(Intent.DEBUG_TOGGLE, true);

        ignoreTutorialCheck.set(Intent.CHEATS_DISABLE, true);
        ignoreTutorialCheck.set(Intent.CHEATS_ENABLE, true);
        ignoreTutorialCheck.set(Intent.CHEATS_MANA_ADD, true);
        ignoreTutorialCheck.set(Intent.CHEATS_MONEY_ADD, true);
        ignoreTutorialCheck.set(Intent.CHEATS_KILL_ALL_ENEMIES, true);
        ignoreTutorialCheck.set(Intent.CHEATS_RESTORE_HP, true);

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