package shared.project.model;
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

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        modelRestore();
    }

    public function modelRestore():Void {

    }

    private function createPlayer():LevelPlayerStruct {
        return {}
    }

    private function createEnemy():LevelPlayerStruct {
        return {}
    }

    private function createRoadPart(x:Int, y:Int, type:RoadType):LevelRoadPart {
        return {x:x, y:y, type:type, idx:x * 10 + y};
    }

    private function levelFirstInitial():LevelStruct {
        var player = createPlayer();
        var enemy = createEnemy();
        var level:LevelStruct = {
            player:createPlayer(),
            enemy:createEnemy(),
            castles:new Array<CastleStruct>(),
            roads:new Array<Array<LevelRoadPart>>()
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
        if(level == null){
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
    }




    function castlesGetByIdx(idx:Int):CastleStruct{
        var level = world.storageGet().level;
        if(level == null){throw "no level model castlesGetByIdx";}
        return level.castles[idx];
    }
    function roadsGetByIdx(idx:Int):Array<LevelRoadPart>{
        var level = world.storageGet().level;
        if(level == null){throw "no level model roadsGetByIdx";}
        return level.roads[idx];
    }

}
