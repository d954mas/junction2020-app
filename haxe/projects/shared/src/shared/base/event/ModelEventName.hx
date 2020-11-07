package shared.base.event;

import shared.project.enums.UnitType.MageType;
import shared.project.storage.Storage.ResourceUnitStruct;
import shared.project.storage.Storage.BattleUnitStruct;
import shared.project.model.World;
enum abstract ModelEventName(String) {
    var TUTORIAL_STARTED;
    var TUTORIAL_COMPLETED;
    var TUTORIAL_PART_CHANGED;
    var LEVEL_NEW;
    var LEVEL_MOVE_TO_NEXT;
    var LEVEL_NEXT_TURN;
    var LEVEL_TURN_START;
    var LEVEL_TURN_END;
    var LEVEL_MONEY_CHANGE;
    var LEVEL_MANA_CHANGE;
    var LEVEL_UNIT_SPAWN;
    var LEVEL_UNIT_MOVE;
    var LEVEL_UNIT_ATTACK;
    var LEVEL_UNIT_DIED;
    var LEVEL_UNIT_DIED_MOVE_TO_NEXT_CASTLE;
    var LEVEL_PLAYER_LOST;
    var LEVEL_CASTLE_ENEMY_DESTROY;
    var LEVEL_RESTART;
    var LEVEL_CARAVAN_SPAWN;
    var LEVEL_CAST_SPELL_START;
    var LEVEL_CAST_SPELL_END;
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

    public static function levelMoneyChange(world:World, count:Int, tag:String):Void {
        world.eventEmit(LEVEL_MONEY_CHANGE, {count:count, tag:tag});
    }

    public static function levelManaChange(world:World, count:Int, tag:String):Void {
        world.eventEmit(LEVEL_MANA_CHANGE, {count:count, tag:tag});
    }

    public static function levelUnitSpawn(world:World, id:Int, struct:BattleUnitStruct):Void {
        var struct = Reflect.copy(struct);//copy struct. Unit view use it for default values
        world.eventEmit(LEVEL_UNIT_SPAWN, {id:id, struct:struct});
    }

    public static function levelCaravanSpawn(world:World, id:Int, struct:ResourceUnitStruct) {
        var struct = Reflect.copy(struct);
        world.eventEmit(LEVEL_CARAVAN_SPAWN, {id:id, struct:struct});
    }

    public static function levelUnitMove(world:World, id:Int, roadId:Int):Void {
        world.eventEmit(LEVEL_UNIT_MOVE, {id:id, roadId:roadId});
    }

    public static function levelUnitAttack(world:World, attackerId:Int, defenderId:Int):Void {
        world.eventEmit(LEVEL_UNIT_ATTACK, {attackerId:attackerId, defenderId:defenderId});
    }

    public static function levelUnitDied(world:World, id:Int) {
        world.eventEmit(LEVEL_UNIT_DIED, {id:id});
    }
    public static function levelUnitDiedMoveToNextCastle(world:World, id:Int) {
        world.eventEmit(LEVEL_UNIT_DIED_MOVE_TO_NEXT_CASTLE, {id:id});
    }

    public static function levelLost(world:World) {
        world.eventEmit(LEVEL_PLAYER_LOST);
    }

    public static function levelTurnStart(world:World) {
        world.eventEmit(LEVEL_TURN_START);
    }

    public static function levelTurnEnd(world:World) {
        world.eventEmit(LEVEL_TURN_END);
    }
    public static function levelRestart(world:World) {
        world.eventEmit(LEVEL_RESTART);
    }
    public static function levelCastleEnemyDestroy(world:World) {
        world.eventEmit(LEVEL_CASTLE_ENEMY_DESTROY);
    }

    public static function levelCastSpellStart(world:World,type:MageType) {
        world.eventEmit(LEVEL_CAST_SPELL_START,{type:type});
    }

    public static function levelCastSpellEnd(world:World,type:MageType) {
        world.eventEmit(LEVEL_CAST_SPELL_END,{type:type});
    }
}

