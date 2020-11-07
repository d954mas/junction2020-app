package shared.base.event;

import shared.project.model.World;
enum abstract ModelEventName(String) {
    var TUTORIAL_STARTED;
    var TUTORIAL_COMPLETED;
    var TUTORIAL_PART_CHANGED;
    var LEVEL_NEW;
    var LEVEL_MOVE_TO_NEXT;
    var LEVEL_NEXT_TURN;
    var LEVEL_MONEY_CHANGE;
    var LEVEL_MANA_CHANGE;
    var LEVEL_UNIT_SPAWN;
}

class EventHelper {

    public static function levelNew(world:World):Void {
        world.eventEmit(LEVEL_NEW);
    }

    public static function levelMoveToNext(world:World):Void {
        world.eventEmit(LEVEL_MOVE_TO_NEXT);
    }

    public static function levelNextTurn(world:World):Void {
        world.eventEmit(LEVEL_NEXT_TURN);
    }

    public static function levelMoneyChange(world:World,count:Int,tag:String):Void {
        world.eventEmit(LEVEL_MONEY_CHANGE,{count:count,tag:tag});
    }
    public static function levelManaChange(world:World,count:Int,tag:String):Void {
        world.eventEmit(LEVEL_MANA_CHANGE,{count:count,tag:tag});
    }
    public static function levelUnitSpawn(world:World,id:Int):Void {
        world.eventEmit(LEVEL_UNIT_SPAWN,{id:id});
    }
}

