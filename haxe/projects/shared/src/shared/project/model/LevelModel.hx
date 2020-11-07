package shared.project.model;
import shared.project.model.units.BasicUnitModel;
import shared.project.storage.Storage.BattleUnitStruct;
import shared.project.configs.UnitConfig;
import shared.project.enums.UnitType;
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
    public var enemyModel:EnemyModel;
    private var battleUnitModels:List<BattleUnitModel>;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        this.playerModel = new PlayerModel(world);
        this.enemyModel = new EnemyModel(world);
        this.battleUnitModels = new List<BattleUnitModel>();
        modelRestore();
    }


    private function addUnit(unit:BattleUnitModel) {
        battleUnitModels.push(unit);
        EventHelper.levelUnitSpawn(world, unit.getId());
    }

    public function modelRestore():Void {
        if (ds.level != null) {
            //lua плохо реагирует на пустой массив
            if (Reflect.hasField(ds.level.units, "length")) {
                for (unit in ds.level.units) {
                    battleUnitModels.add(new BattleUnitModel(unit, world));
                }
            }
        }
    }

    public function unitsSpawnUnit(ownerId:Int, type:UnitType, unitLevel:Int) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level in unitsSpawnUnit";}
        var scales = UnitConfig.scalesByUnitType[type];
        if (scales == null) {throw "no scales in unitsSpawnUnit";}
        var unit:BattleUnitStruct = {
            roadPartIdx:-1,
            id:level.unitIdx,
            hpLvl:unitLevel,
            hp:scales.hpByLevel[unitLevel],
            ownerId:ownerId,
            type:type,
            attackLvl:unitLevel,
            attackRange:scales.attackRange,
            reward:scales.rewardByLevel[unitLevel]
        }
        level.unitIdx++;

        //ADD CHECK THAT NO UNITS IN SPAWN POINT

        var road = level.roads[level.roads.length - 1];
        //PLAYER
        if (ownerId == 0) {
            unit.roadPartIdx = road[0].idx;
        } else { //ENEMY
            unit.roadPartIdx = road[road.length - 1].idx;
        }

        level.units.push(unit);
        addUnit(new BattleUnitModel(unit, world));
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
            if (canAttack.length == 0) {
                if (attacker.canMove()) {
                    var newPos:LevelRoadPart;
                    //if (attacker.getOwnerId() > 0) { //Не понял и закомментировал. Почему ходит только враг
                    newPos = unitNewPosition(attacker);
                    attacker.move(newPos.idx);
                    // }
                }
            } else {
                var defender = canAttack[0];
                attacker.attack(defender);
            }
        }
        removeDeadUnits();
    }

    @:nullSafety(Off)
    private function removeDeadUnits() {
        var dead = Lambda.filter(ds.level.units, function(u) {return u.hp == 0;});
        var deadModels = Lambda.filter(battleUnitModels, function(u) {return !u.isAlive();});
        for (unit in dead) {
            ds.level.units.remove(unit);
        }
        for (unit in deadModels) {
            EventHelper.levelUnitDied(world, unit.getId());
            battleUnitModels.remove(unit);
        }
    }

    private function unitNewPosition(unit:IBattleUnit) {
        var road = roadByRoadPart(unit.getPos());
        if (unit.getOwnerId() > 0) {
            //change behavior if enemies can go off the roadPlayerToEnemy, current behavior
            //might cause IndexOutOfBoundsException
            var id = road.indexOf(unit.getPos()) - 1;
            if (id < 0) {id = 0;}
            return road[id];
        }
        var id = road.indexOf(unit.getPos()) + 1;
        if (id >= road.length) {id = road.length - 1;}
        return road[id];
    }

    private function roadByRoadPart(part:LevelRoadPart) {
        if (ds.level != null) {
            for (road in ds.level.roads) {
                if (road.indexOf(part) != -1) return road;
            }
        }
        throw "Part doesnt belong to any road";
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

    public function levelNextTurn() {
        var level = world.storageGet().level;
        if (level == null) { throw "no level in levelNextTurn";}
        EventHelper.levelNextTurn(world);
        level.turn++;
        enemyModel.turn();
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
            unitIdx:0,
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

        roadResToPlayer.push(createRoadPart(0, 0, RoadType.CASTLE));
        roadResToPlayer.push(createRoadPart(1, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(2, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(3, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(4, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(5, 0, RoadType.BASE));
        roadResToPlayer.push(createRoadPart(6, 0, RoadType.CASTLE));

        var roadPlayerToEnemy:Array<LevelRoadPart> = new Array<LevelRoadPart>();

        roadPlayerToEnemy.push(createRoadPart(7, 0, RoadType.CASTLE));
        roadPlayerToEnemy.push(createRoadPart(8, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(9, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(10, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(11, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(12, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(13, 0, RoadType.CASTLE));

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
        roadPlayerToEnemy.push(createRoadPart(startX + 1, 0, RoadType.CASTLE));
        roadPlayerToEnemy.push(createRoadPart(startX + 2, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 3, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 4, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 5, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 6, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 7, 0, RoadType.CASTLE));

        level.roads.push(roadPlayerToEnemy);

        EventHelper.levelMoveToNext(world);
    }


    public function castlesGetByIdx(idx:Int):CastleStruct {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model castlesGetByIdx";}
        return level.castles[idx];
    }

    public function roadsGetByIdx(idx:Int):Array<LevelRoadPart> {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model roadsGetByIdx";}
        return level.roads[idx];
    }

    public function unitsGetUnitById(id:Int):Null<BattleUnitModel> {
        for (model in battleUnitModels) {
            if (model.getId() == id) {
                return model;
            }
        }
        return null;
    }

    public function roadsFindPartById(id):LevelRoadPart {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model roadsFindPartById";}
        var roadX = Math.floor(id / 1000);
        var roadIdx = Math.floor(roadX / 7);
        var road = roadsGetByIdx(roadIdx);
        for (roadPart in road) {
            if (roadPart.idx == id) {
                return roadPart;
            }
        }
        //check all roads if not find
        for (road in level.roads) {
            for (roadPart in road) {
                if (roadPart.idx == id) {
                    return roadPart;
                }
            }
        }
        throw "no road with id:" + id;
    }

}
