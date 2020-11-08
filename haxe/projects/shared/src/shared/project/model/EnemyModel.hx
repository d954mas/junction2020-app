package shared.project.model;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.configs.GameConfig;
import shared.project.enums.UnitType;
import shared.project.storage.Storage;

typedef EnemyModelAITurn = {
var spawn_percent:Float;
var knight:Float;
var archer:Float;
var shield:Float;
var spearman:Float;
var mage:Float;
};


@:expose @:keep
class EnemyModel {
    private var world:World;
    private var ds:StorageStruct;
    private var ai:Array<EnemyModelAITurn> = [
        {spawn_percent:0, knight:0.5, archer:0.5, shield:0, spearman:0, mage:0},
        {spawn_percent:1, knight:0.5, archer:0.5, shield:0, spearman:0, mage:0},
        {spawn_percent:0, knight:0.5, archer:0.5, shield:0, spearman:0, mage:0},
        {spawn_percent:1, knight:0.5, archer:0.5, shield:0, spearman:0, mage:0},
        {spawn_percent:0, knight:0.5, archer:0.5, shield:0, spearman:0, mage:0},

        {spawn_percent:1, knight:0.5, archer:0.5, shield:0, spearman:0, mage:0},
        {spawn_percent:0.5, knight:0.33, archer:0.33, shield:0.33, spearman:0, mage:0},
        {spawn_percent:1, knight:0.33, archer:0.33, shield:0.33, spearman:0, mage:0},
        {spawn_percent:0.5, knight:0.33, archer:0.33, shield:0.33, spearman:0, mage:0},
        {spawn_percent:1, knight:0.33, archer:0.33, shield:0.33, spearman:0, mage:0},

        {spawn_percent:0.5, knight:0.33, archer:0.33, shield:0.33, spearman:0, mage:0},
        {spawn_percent:1, knight:0.25, archer:0.25, shield:0.25, spearman:0, mage:0},
        {spawn_percent:0.5, knight:0.25, archer:0.25, shield:0.25, spearman:0, mage:0},
        {spawn_percent:0, knight:0.25, archer:0.25, shield:0.25, spearman:0, mage:0},
        {spawn_percent:0.5, knight:0.25, archer:0.25, shield:0.25, spearman:0, mage:0},

        {spawn_percent:1, knight:0.25, archer:0.25, shield:0.25, spearman:0.25, mage:0},
        {spawn_percent:0.5, knight:0.2, archer:0.2, shield:0.3, spearman:0.3, mage:0},
        {spawn_percent:1, knight:0.2, archer:0.2, shield:0.3, spearman:0.3, mage:0},
        {spawn_percent:0.1, knight:0.15, archer:0.15, shield:0.35, spearman:0.3, mage:0},
        {spawn_percent:0.5, knight:0.1, archer:0.1, shield:0.4, spearman:0.4, mage:0},

        {spawn_percent:1, knight:0.05, archer:0.5, shield:0.2, spearman:0.2, mage:0.5},

    ];

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
        if (level.ice > 0) {return;}
        var step = level.turnEnemyAI % ai.length;
        var data:EnemyModelAITurn = ai[level.turnEnemyAI];
        if (data.spawn_percent >= Math.random()) {
            var chance = Math.random();
            if(data.knight>=chance){
                unitsSpawnUnit(UnitType.KNIGHT);
            }else if(data.knight+data.archer>=chance){
                unitsSpawnUnit(UnitType.ARCHER);
            }else if(data.knight+data.archer+data.shield>=chance){
                unitsSpawnUnit(UnitType.SHIELD);
            }else if(data.knight+data.archer+data.shield+data.spearman>=chance){
                unitsSpawnUnit(UnitType.SPEARMAN);
            }else if(data.knight+data.archer+data.shield+data.spearman+data.mage>=chance){
                unitsSpawnUnit(UnitType.MAGE);
            }
        }
        level.turnEnemyAI++;
    }


}
