package shared.project.model;
import shared.project.enums.GameEnums.RoadType;
import shared.project.storage.Storage;
import shared.project.storage.Storage.LevelPlayerStruct;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.storage.Storage.LevelStruct;
import shared.base.model.BaseModel;
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
        return {

        }
    }

    private function createEnemy():LevelPlayerStruct {
        return {

        }
    }

    private function createRoadPart(x:Int, y:Int, type:RoadType):LevelRoadPart {
        return {x:x, y:y, type:type, idx:x*10+y};
    }

    private function createPrevLevelForFirstGame():LevelStruct {
        var level:LevelStruct = {
            player:createPlayer(),
            enemy:createEnemy(),
            roadToEnemy:new Array<LevelRoadPart>(),
        }
        level.roadToEnemy.push(createRoadPart(0,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(1,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(2,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(3,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(4,0,RoadType.BASE));


        return level;
    }

    public function createLevel() {
        var prevLevel = world.storageGet().level;
        if (prevLevel == null) {
            prevLevel = createPrevLevelForFirstGame();
        }
        var level:LevelStruct = {
            player:createPlayer(),
            enemy:createEnemy(),
            roadToEnemy:new Array<LevelRoadPart>(),
        }
        var startX = prevLevel.roadToEnemy[prevLevel.roadToEnemy.length-1].x;
        level.roadToEnemy.push(createRoadPart(startX+1,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(startX+2,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(startX+3,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(startX+4,0,RoadType.BASE));
        level.roadToEnemy.push(createRoadPart(startX+5,0,RoadType.BASE));

        world.storageGet().levelPrev = prevLevel;
        world.storageGet().level = level;

        EventHelper.levelNew(world);
    }

}
