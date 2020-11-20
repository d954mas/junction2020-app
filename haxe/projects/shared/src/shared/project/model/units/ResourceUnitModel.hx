package shared.project.model.units;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.LevelRoadPart;
import shared.project.enums.UnitType;
import shared.project.storage.Storage.ResourceUnitStruct;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.storage.Storage.BasicUnitStruct;
class ResourceUnitModel implements IBasicUnit {
    private var struct:ResourceUnitStruct;
    private var world:World;

    public function new(struct:ResourceUnitStruct, world:World) {
        this.struct = struct;
        this.world = world;
    }

    public function getPos():LevelRoadPart {
        return world.levelModel.roadsFindPartById(struct.roadPartIdx);
    }

    public function canMove():Bool {
        return true;
    }

    public function move(roadPartIdx:Int):Void {
        struct.roadPartIdx = roadPartIdx;
        EventHelper.levelUnitMove(world, getId(), roadPartIdx);
        EventHelper.levelCaravanMove(world, getId(), roadPartIdx);
    }

    public function getOwnerId():Int {
        return struct.ownerId;
    }

    public function getId():Int {
        return struct.id;
    }

    public function getResources():Int {
        return struct.resources;
    }

    public function canLoad():Bool {
        var level = world.levelModel;
        if (struct.resources == 0 && level.getResourceCastlePos().idx == struct.roadPartIdx) return true;
        else return false;
    }

    public function loadResources() {
        if (canLoad()) {
            struct.resources += UnitConfig.resourceScale[struct.resourceLvl];
            EventHelper.levelCaravanLoad(world, struct.id);
        }
    }

    public function canUnload():Bool {
        if (struct.resources > 0 && world.levelModel.getUnloadPos().idx == struct.roadPartIdx) return true;
        else return false;
    }

    @:nullSafety(Off)
    public function unloadResources() {
        if (canUnload()) {
            EventHelper.levelCaravanUnLoad(world, struct.id);
            world.levelModel.playerModel.moneyChange(struct.resources,"caravan");
            struct.resources = 0;
        }
    }

    public function getStruct() {
        return struct;
    }
}
