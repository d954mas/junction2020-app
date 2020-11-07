package shared.project.model;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.configs.GameConfig;
import shared.project.enums.UnitType;
import shared.project.storage.Storage;

@:expose @:keep
class EnemyModel {
    private var world:World;
    private var ds:StorageStruct;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        modelRestore();
    }

    public function unitsSpawnUnit(unitType:UnitType) {
        world.levelModel.unitsSpawnUnit(1, unitType, 0);
        world.speechBuilder.text("enemy spawn " + unitType);
    }

    public function modelRestore():Void {

    }

    public function turn() {
        var level = world.storageGet().level;
        if (level == null) {throw "enemy can't turn no level";}
        if(level.ice>0){return;}
        var step = level.turnEnemyAI % 6;
        if (step == 2) {
            var chance = Math.random();
            if (chance < 0.5) {
                unitsSpawnUnit(UnitType.KNIGHT);
            } else if (chance < 0.8) {
                unitsSpawnUnit(UnitType.SHIELD);
            } else {
                unitsSpawnUnit(UnitType.SPEARMAN);
            }
        } else if (step == 5) {
            var chance = Math.random();
            if (chance < 0.5) {
                unitsSpawnUnit(UnitType.ARCHER);
            } else if (chance < 0.8) {
                unitsSpawnUnit(UnitType.MAGE);
            } else {
                unitsSpawnUnit(UnitType.KNIGHT);
            }
        }
        level.turnEnemyAI++;
    }


}
