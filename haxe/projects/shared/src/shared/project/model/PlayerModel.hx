package shared.project.model;
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

    public function unitsSpawnUnit(unitType:UnitType) {
        world.levelModel.unitsSpawnUnit(0, unitType, 0);
        world.speechBuilder.text("spawn " + unitType);
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
