package shared.project.model;
import shared.project.model.units.BattleUnitModel;
import Array;
import shared.project.enums.GameEnums.RoadType;
import shared.project.storage.Storage;
import shared.project.storage.Storage.LevelPlayerStruct;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.storage.Storage.LevelStruct;
import shared.base.model.BaseModel;

@:expose @:keep
class LevelModel {
    private var world:World;
    private var ds:StorageStruct;
    public var playerModel:PlayerModel;
    private var battleUnitModels:List<BattleUnitModel>;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        this.playerModel = new PlayerModel(world);
        this.battleUnitModels = new List<BattleUnitModel>();
        modelRestore();
    }

    public function addUnit(unit:BattleUnitModel) {

    }

    public function modelRestore():Void {
        if (ds.level != null ) {
            //lua плохо реагирует на пустой массив
            if (Reflect.hasField(ds.level.units, "length")) {
                for (unit in ds.level.units) {
                    battleUnitModels.add(new BattleUnitModel(unit));
                }
            }
        }
    }

    private function createPlayer():LevelPlayerStruct {
        return {
            id: 0,
            mana:0,
            money:20,
        }
    }

    private function createEnemy():LevelEnemyStruct {
        return {
            id: 1,
        }
    }

    private function createRoadPart(x:Int, y:Int, type:RoadType):LevelRoadPart {
        return {x:x, y:y, type:type, idx:x * 1000 + y};
    }

    private function levelNextTurnBattles() {
        for (attacker in battleUnitModels) {
            var canAttack = Lambda.filter(battleUnitModels, function(v) {return attacker.canAttack(v);});
        }
    }

    private function levelNextTurnCaravans() {}

    private function levelNextTurnRegenMoney() {
        var money = 0; //todo add money regen count;
        playerModel.moneyChange(money, "startTurnRegen");
    }

    private function levelNextTurnRegenMana() {
        var mana = 5; //todo add money regen count;
        playerModel.manaChange(mana, "startTurnRegen");
    }

    private function levelNextCheckWinLose() {}

    private function levelNextTurn() {
        var level = world.storageGet().level;
        if (level == null) { throw "no level in levelNextTurn";}
        EventHelper.levelNextTurn(world);
        level.turn++;
        levelNextTurnBattles();
        levelNextTurnCaravans();

        levelNextTurnRegenMoney();
        levelNextTurnRegenMana();

        levelNextCheckWinLose();

        //add
    }

    private function levelFirstInitial():LevelStruct {
        var player = createPlayer();
        var enemy = createEnemy();
        var level:LevelStruct = {
            turn:0,
            player:createPlayer(),
            enemy:createEnemy(),
            castles:new Array<CastleStruct>(),
            roads:new Array<Array<LevelRoadPart>>(),
            units:new Array<BattleUnitStruct>()
        }
        level.castles.push({idx:level.castles.length}); //resources_castle
        level.castles.push({idx:level.castles.length});//player_castle
        level.castles.push({idx:level.castles.length}); //enemy_castle

        var roadResToPlayer:Array<LevelRoadPart> = new Array<LevelRoadPart>();

        roadResToPlayer.push(createRoadPart(0, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(1, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(2, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(3, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(4, 0, RoadType.BASE));

        var roadPlayerToEnemy:Array<LevelRoadPart> = new Array<LevelRoadPart>();

        roadPlayerToEnemy.push(createRoadPart(5, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(6, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(7, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(8, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(9, 0, RoadType.BASE));

        level.roads.push(roadResToPlayer);
        level.roads.push(roadPlayerToEnemy);


        return level;
    }

    public function createLevel() {
        if (world.storageGet().level == null) {
            world.storageGet().level = levelFirstInitial();
            EventHelper.levelNew(world);
        } else {
            throw "level already created";
        }
    }

    public function levelNextCastle() {
        var level = world.storageGet().level;
        if (level == null) {
            throw "can't move to next castle level storage is null";
        }
        var enemy = createEnemy();
        level.enemy = enemy;
        var lastRoad = level.roads[level.roads.length - 1];
        var startX = lastRoad[lastRoad.length - 1].x;

        level.castles.push({idx:level.castles.length}); //enemy_castle

        var roadPlayerToEnemy:Array<LevelRoadPart> = new Array<LevelRoadPart>();
        roadPlayerToEnemy.push(createRoadPart(startX + 1, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 2, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 3, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 4, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 5, 0, RoadType.BASE));

        level.roads.push(roadPlayerToEnemy);

        EventHelper.levelMoveToNext(world);
    }


    function castlesGetByIdx(idx:Int):CastleStruct {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model castlesGetByIdx";}
        return level.castles[idx];
    }

    function roadsGetByIdx(idx:Int):Array<LevelRoadPart> {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model roadsGetByIdx";}
        return level.roads[idx];
    }

}
