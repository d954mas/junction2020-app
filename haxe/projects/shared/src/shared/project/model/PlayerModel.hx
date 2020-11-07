package shared.project.model;
import shared.project.configs.UnitConfig;
import shared.project.enums.UnitType;
import shared.project.configs.GameConfig;
import Array;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.enums.GameEnums.RoadType;
import shared.project.storage.Storage.LevelPlayerStruct;
import shared.project.storage.Storage.LevelStruct;
import shared.project.storage.Storage;

@:expose @:keep
class PlayerModel {
    private var world:World;
    private var ds:StorageStruct;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        modelRestore();
    }

    @:nullSafety(Off)
    public function spawnCaravan():Bool {
        var success = world.levelModel.spawnCaravan(ds.level.player.caravanLevel);
        if (success) {
            EventHelper.levelTurnStart(world);
            world.speechBuilder.text("spawned caravan");
            world.levelModel.levelNextTurn();
        }
        return success;
    }

    public function unitsSpawnUnit(unitType:UnitType, amount:Int) {
        EventHelper.levelTurnStart(world);
        world.levelModel.enqueueUnits(0, unitType, amount);
        world.speechBuilder.text("enqueued " + unitType);
        //spawn это ход игрока

        world.levelModel.levelNextTurn();
    }

    public function modelRestore():Void {

    }

    //tag for visual. To understand how to show
    public function moneyChange(value:Int, tag:String) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:moneyChange";}
        if (value == 0) {return;}
        if (level.player.money + value < 0) {throw "not enought money";}

        level.player.money += value;
        EventHelper.levelMoneyChange(world, value, tag);
    }

    public function canSpendMoney(value:Int) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:moneyChange";}
        return (level.player.money >= value);
    }

    public function castSpell(type:MageType){
        EventHelper.levelTurnStart(world);

        EventHelper.levelCastSpellStart(world,type);
        EventHelper.levelCastSpellEnd(world,type);

        world.levelModel.levelNextTurn();
    }

    public function canSpendMana(value:Int) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:moneyChange";}
        return (level.player.mana >= value);
    }

    public function unitGetPrice(type:UnitType){
        var scales = UnitConfig.scalesByUnitType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.costByLevel[0];
        return price;
    }

    public function mageGetPrice(type:MageType){
        var scales = MageConfig.scalesByMageType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.costByLevel[0];
        return price;
    }
    public function mageGetPower(type:MageType){
        var scales = MageConfig.scalesByMageType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.powerByLevel[0];
        return price;
    }


    public function manaChange(value:Int, tag:String) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:manaChange";}
        if (value == 0) {return;}
        if (level.player.mana + value < 0) {throw "not enought mana";}
        if (level.player.mana + value > GameConfig.MAX_MANA) {
            value = GameConfig.MAX_MANA - level.player.mana;
        }
        if (value == 0) {return;}
        level.player.mana += value;
        EventHelper.levelManaChange(world, value, tag);
    }


}
