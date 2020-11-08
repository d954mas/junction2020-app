package shared.project.model;
import shared.project.model.units.ResourceUnitModel;
import shared.project.configs.GameConfig;
import shared.base.enums.ContextName;
import shared.project.model.units.CastleUnitModel;
import shared.project.model.units.CastleUnitModel;
import shared.project.model.units.BasicUnitModel;
import shared.project.storage.Storage.BattleUnitStruct;
import shared.project.configs.UnitConfig;
import shared.project.enums.UnitType;
import shared.project.model.units.BattleUnitModel;
import Array;
import haxe.DynamicAccess;
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
    public var battleUnitModels:List<BattleUnitModel>;
    private var resourceUnitModels:List<ResourceUnitModel>;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        this.playerModel = new PlayerModel(world);
        this.enemyModel = new EnemyModel(world);
        this.battleUnitModels = new List<BattleUnitModel>();
        this.resourceUnitModels = new List<ResourceUnitModel>();
        modelRestore();
    }

    public function restart() {
        var storage = world.storageGet();
        if (storage.level != null) {
            EventHelper.levelRestart(world);
        }
        storage.level = null;
        if (storage.level == null) {
            createLevel();
        }
    }

    private function addUnit(unit:BattleUnitModel) {
        battleUnitModels.add(unit);
        EventHelper.levelUnitSpawn(world, unit.getId(), unit.getStruct());
    }

    private function addUnitCastle(unit:BattleUnitModel) {
        battleUnitModels.add(unit);
        //EventHelper.levelUnitSpawn(world, unit.getId());
    }

    public function modelRestore():Void {
        if (ds.level != null) {
            //lua плохо реагирует на пустой массив
            if (Reflect.hasField(ds.level.units, "length")) {
                for (unit in ds.level.units) {
                    if (unit.type == UnitType.CASTLE) {
                        battleUnitModels.add(new CastleUnitModel(unit, world));
                    } else {
                        battleUnitModels.add(new BattleUnitModel(unit, world));
                    }

                }
            }
            trace("DBG_CAR: " + Std.string(ds.level.caravans));
            if (Reflect.hasField(ds.level.caravans, "length")) {
                for (caravan in ds.level.caravans) {
                    resourceUnitModels.add(new ResourceUnitModel(caravan, world));
                }
            }
        }
    }

    public function enqueueUnits(ownerId:Int, type:UnitType, amount:Int) {
        var counter = amount;
        var owner = getPlayerById(ownerId);
        while (counter > 0) {
            owner.unitQueue.push({ownerId:ownerId, unitType:type});
            counter--;
        }
    }

    public function dequeUnits(ownerId:Int, type:UnitType, amount:Int) {
        var counter = amount;
        var owner = getPlayerById(ownerId);
        if (owner != null) {
            var queuedOfType = Lambda.filter(owner.unitQueue, function(v) {return v.unitType == type;});
            for (unit in queuedOfType) {
                owner.unitQueue.remove(unit);
                counter--;
                if (counter == 0) break;
            }
        }
    }

    public function unitsSpawnUnitCastle(ownerId:Int, unitLevel:Int):CastleUnitModel {
        var level = world.storageGet().level;
        var type = UnitType.CASTLE;
        if (level == null) {throw "no level in unitsSpawnUnitCastle";}
        var scales = UnitConfig.scalesByUnitType[type];
        if (scales == null) {throw "no scales in unitsSpawnUnitCastle";}
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

        var road = level.roads[level.roads.length - 1];
        //PLAYER
        if (ownerId == 0) {
            unit.roadPartIdx = road[0].idx;
        } else { //ENEMY
            unit.roadPartIdx = road[road.length - 1].idx;
        }

        level.units.push(unit);
        var model = new CastleUnitModel(unit, world);
        addUnitCastle(model);
        return model;
    }

    @:nullSafety(Off)
    public function getResourceCastlePos() {
        return ds.level.roads[ds.level.roads.length - 2][0];
    }

    @:nullSafety(Off)
    public function getUnloadPos() {
        var road = ds.level.roads[ds.level.roads.length - 2];
        return road[road.length - 1];
    }

    @:nullSafety(Off)
    public function spawnCaravan(level:Int):Bool {
        if (ds.level.caravans.length < playerModel.caravanGetMax()) {
            var caravan = {
                roadPartIdx:getUnloadPos().idx,
                ownerId:0,
                id: ds.level.caravanIdx,
                resources:0,
                resourceLvl:level
            }
            ds.level.caravanIdx++;
            ds.level.caravans.push(caravan);
            var model = new ResourceUnitModel(caravan, world);
            addCaravan(model);
            return true;
        }
        return false;
    }

    private function addCaravan(model:ResourceUnitModel) {
        resourceUnitModels.add(model);
        EventHelper.levelCaravanSpawn(world, model.getId(), model.getStruct());
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
        var roadPartIdx:Int;
        if (ownerId == 0) {
            roadPartIdx = road[0].idx;
        } else { //ENEMY
            roadPartIdx = road[road.length - 1].idx;
        }

        if (canMoveToPart(roadPartIdx)) {
            unit.roadPartIdx = roadPartIdx;
            level.units.push(unit);
            addUnit(new BattleUnitModel(unit, world));
            return true;
        }
        else return false;
    }

    private function canMoveToPart(partIdx:Int) {
        @:nullSafety(Off)
        return Lambda.count(ds.level.units, function(v) {return v.type != UnitType.CASTLE && v.roadPartIdx == partIdx;}) == 0;
    }

    private function createPlayer():LevelPlayerStruct {
        var unitLevels:DynamicAccess<Int> = new DynamicAccess<Int>();
        for (type in UnitType.ALL_TYPES) {
            unitLevels[Std.string(type)] = 1;
        }
        return {
            id: 0,
            unitLevels: unitLevels,
            caravanLevel:1,
            unitQueue:new Array<UnitQueueEntry>(),
            mana:GameConfig.START_MANA,
            money:GameConfig.START_MONEY,
        }
    }

    private function createEnemy():LevelEnemyStruct {
        var unitLevels:DynamicAccess<Int> = new DynamicAccess<Int>();
        for (type in UnitType.ALL_TYPES) {
            unitLevels[Std.string(type)] = 1;
        }
        return {
            id: 1,
            unitLevels:unitLevels,
            unitQueue:new Array<UnitQueueEntry>(),
        }
    }

    private function createRoadPart(x:Int, y:Int, type:RoadType):LevelRoadPart {
        return {x:x, y:y, type:type, idx:x * 1000 + y};
    }

    private function levelNextTurnBattles() {
        var madeTurn:Map<BattleUnitModel, Bool> = new Map<BattleUnitModel, Bool>();
        for (attacker in battleUnitModels) {
            var canAttack = Lambda.filter(battleUnitModels, function(v) {return attacker.canAttack(v);});
            haxe.ds.ArraySort.sort(canAttack, function(a, b) {
                if (a.canMove() && !b.canMove()) return -1;
                else if (!a.canMove() && b.canMove()) return 1;
/*                    else if (a.getHp() < b.getHp()) return -1;
                    else if (a.getHp() > b.getHp()) return 1;*/
                else return 0;
            });
            if (canAttack.length == 0) {
                if (attacker.canMove()) {
                    if (madeTurn[attacker] == null) {
                        var newPos:LevelRoadPart;
                        //if (attacker.getOwnerId() > 0) { //Не понял и закомментировал. Почему ходит только враг
                        newPos = unitNewPosition(attacker);
                        if (canMoveToPart(newPos.idx)) {
                            attacker.move(newPos.idx);
                            madeTurn[attacker] = true;
                        }
                    }
                    // }
                }
            } else {
                var defender = canAttack[0];
                if (madeTurn[attacker] == null) {
                    attacker.attack(defender);
                    madeTurn[attacker] = true;
                    if (madeTurn[defender] == null && defender.canAttack(attacker)) {
                        defender.attack(attacker);
                        madeTurn[defender] = true;
                    }
                }
            }
        }
        removeDeadUnits();
    }

    @:nullSafety(Off)
    public function removeDeadUnits() {
        var dead = Lambda.filter(ds.level.units, function(u) {return u.hp == 0;});
        var deadModels = Lambda.filter(battleUnitModels, function(u) {return !u.isAlive();});
        for (unit in dead) {
            ds.level.units.remove(unit);
            var unitModel = unitsGetUnitById(unit.id);
            if (unit.type == UnitType.CASTLE) {
                // var castle = Lambda.find(ds.level.castles, function (v) {return v.unitId == unit.id;});
                // ds.level.castles.remove(castle);
            } else {
                EventHelper.levelUnitDied(world, unit.id);
                if (unitModel.getOwnerId() > 0) {
                    world.levelModel.playerModel.moneyChange(unitModel.getReward(), "kill enemy");
                }
                battleUnitModels.remove(unitModel);
            }

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

    private function levelNextTurnCaravans() {
        var caravansToRemove = new Array<ResourceUnitModel>();
        for (caravan in resourceUnitModels) {
            if (caravan.canLoad()) {
                trace("can load");
                caravan.loadResources();
            }
            else if (caravan.canUnload()) {
                trace("can unload");
                caravan.unloadResources();
                caravansToRemove.push(caravan);
            } else if (caravan.canMove()) {
                trace("can move");
                caravan.move(caravanNewPos(caravan).idx);
            }
        }
        for (caravan in caravansToRemove) {
            resourceUnitModels.remove(caravan);
        }
    }

    private function caravanNewPos(caravan:ResourceUnitModel) {
        var road = roadByRoadPart(caravan.getPos());
        if (caravan.getResources() > 0) {
            return road[road.indexOf(caravan.getPos()) + 1];
        }
        else return road[road.indexOf(caravan.getPos()) - 1];
    }

    private function levelNextTurnRegenMoney() {
        playerModel.moneyChange(GameConfig.MONEY_REGEN, "startTurnRegen");
    }

    private function levelNextTurnRegenMana() {
        playerModel.manaChange(playerModel.mageGetManaRegen(), "startTurnRegen");
    }


    private function levelNextCheckWinLose() {
        if (ds.level != null) {
            var playerLose = Lambda.count(ds.level.castles,
            function(castle) {
                var unit = unitsGetUnitById(castle.unitId);
                if (unit != null)
                    return (unit.getOwnerId() == 0 && unit.getHp() == 0);
                else throw "no unit levelNextCheckWinLose1 with id:" + castle.unitId;
            }
            ) > 0;
            var allEnemiesLost = Lambda.count(ds.level.castles,
            function(castle) {
                var unit = unitsGetUnitById(castle.unitId);
                if (unit != null) {
                    trace(unit.getOwnerId() + " " + unit.getHp());
                    return (unit.getOwnerId() > 0 && unit.getHp() > 0);
                }
                else throw "no unit levelNextCheckWinLose2 with id:" + castle.unitId;
            }
            ) == 0;
            if (playerLose) {
                ds.level.lose = true;
                world.contextChange(ContextName.LOSE_MODAL);
                EventHelper.levelLost(world);
            }
            else if (allEnemiesLost) {
                levelNextCastle();
            }
        } else throw "no level";
    }

    private function levelNextTurnQueue() {
        var level = ds.level;
        if (level != null) {
            var playerQueue = level.player.unitQueue;
            var enemyQueue = level.enemy.unitQueue;
            if (playerQueue.length > 0) {
                var entry:UnitQueueEntry = playerQueue[0];
                @:nullSafety(Off) var success = unitsSpawnUnit(entry.ownerId, entry.unitType, level.player.unitLevels[Std.string(entry.unitType)]);
                if (success) {
                    playerQueue.shift();
                }
            }
            if (enemyQueue.length > 0) {
                var entry:UnitQueueEntry = enemyQueue[0];
                @:nullSafety(Off) var success = unitsSpawnUnit(entry.ownerId, entry.unitType, level.enemy.unitLevels[Std.string(entry.unitType)]);
                if (success) {
                    enemyQueue.shift();
                }
            }
        }
    }

    public function levelNextTurn() {
        var level = world.storageGet().level;
        if (level == null) { throw "no level in levelNextTurn";}
        if (level.lose) {return;}
        if (level.lose) { throw "can't make turn we lose";}
        EventHelper.levelNextTurn(world);
        level.turn++;
        enemyModel.turn();
        levelNextTurnQueue();
        levelNextTurnBattles();
        levelNextTurnCaravans();

        levelNextTurnRegenMoney();
        levelNextTurnRegenMana();

        if (level.ice > 0) {
            level.ice--;
            if (level.ice == 0) {
                EventHelper.levelSpellIceEnd(world);
            }

        }

        EventHelper.levelTurnEnd(world); //update all animations before turn end
        levelNextCheckWinLose();


        //add
    }

    private function levelFirstInitial():LevelStruct {
        var player = createPlayer();
        var enemy = createEnemy();
        var level:LevelStruct = {
            ice:0,
            mageLevels: {
                FIREBALL:0,
                CARAVAN:0,
                MANA:0,
                ICE:0,
            },
            turnEnemyAI:0,
            turn:0,
            lose:false,
            unitIdx:0,
            caravanIdx:0,
            player:createPlayer(),
            enemy:createEnemy(),
            caravans:new Array<ResourceUnitStruct>(),
            castles:new Array<CastleStruct>(),
            roads:new Array<Array<LevelRoadPart>>(),
            units:new Array<BattleUnitStruct>()
        }
        world.storageGet().level = level;//fix no level when spawn units for castles


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

        var resourceUnit = unitsSpawnUnitCastle(0, 0);
        resourceUnit.getStruct().roadPartIdx = 0;
        level.castles.push({idx:level.castles.length, unitId:resourceUnit.getId()}); //resources_castle
        level.castles.push({idx:level.castles.length, unitId:unitsSpawnUnitCastle(0, 0).getId()});//player_castle
        level.castles.push({idx:level.castles.length, unitId:unitsSpawnUnitCastle(1, 0).getId()}); //enemy_castle


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
        //remove all enemies
        for (unit in level.units) {
            var unitModel = unitsGetUnitById(unit.id);
            if (unit.type == UnitType.CASTLE) {
                // var castle = Lambda.find(ds.level.castles, function (v) {return v.unitId == unit.id;});
                // ds.level.castles.remove(castle);
            } else {
                EventHelper.levelUnitDiedMoveToNextCastle(world, unit.id);
            }
        }

        var enemy = createEnemy();
        level.enemy = enemy;
        var lastRoad = level.roads[level.roads.length - 1];
        var startX = lastRoad[lastRoad.length - 1].x;


        var roadPlayerToEnemy:Array<LevelRoadPart> = new Array<LevelRoadPart>();
        roadPlayerToEnemy.push(createRoadPart(startX + 1, 0, RoadType.CASTLE));
        roadPlayerToEnemy.push(createRoadPart(startX + 2, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 3, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 4, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 5, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 6, 0, RoadType.BASE));
        roadPlayerToEnemy.push(createRoadPart(startX + 7, 0, RoadType.CASTLE));
        level.roads.push(roadPlayerToEnemy);

        var persistCastleUnits = new Array<BattleUnitStruct>();

        var newUserCastle = level.castles.pop();
        //var unitOld = Lambda.find(ds.level.units, function (v) {return v.id == newUserCastle.unitId;});
        // ds.level.units.remove(unitOld)


        //change enemy castle to user castls
        var newUserCastleUnit = unitsSpawnUnitCastle(0, 0);
        var newUserCastleStruct = {idx:level.castles.length, unitId:newUserCastleUnit.getId()}
        level.castles.push(newUserCastleStruct);


        for (castle in level.castles) {
            var castleUnit = unitsGetUnitById(castle.unitId);
            if (castleUnit != null) {
                persistCastleUnits.push((cast (castleUnit, CastleUnitModel)).getStruct());
            }
        }

        persistCastleUnits.push(newUserCastleUnit.getStruct());

        var newUnit = unitsSpawnUnitCastle(1, 0);
        level.castles.push({idx:level.castles.length, unitId:newUnit.getId()}); //new enemy_castle

        persistCastleUnits.push(newUnit.getStruct());

        level.units = new Array<BattleUnitStruct>();
        level.units = level.units.concat(persistCastleUnits);

        if (level.ice > 0) {
            level.ice = 0;
            EventHelper.levelSpellIceEnd(world);
        }

        world.levelModel.playerModel.moneyChange(GameConfig.START_MONEY - level.player.money, "reset castle");
        world.levelModel.playerModel.manaChange(GameConfig.START_MANA - level.player.mana, "reset castle");

        EventHelper.levelCastleEnemyDestroy(world);
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

    public function getPlayerById(id:Int):LevelPlayerOrAiStruct {
        if (ds.level != null) {
            if (id == 0) return ds.level.player;
            else return ds.level.enemy;
        } else throw "no level";
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
