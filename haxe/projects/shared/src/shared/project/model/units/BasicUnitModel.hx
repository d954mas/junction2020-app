package shared.project.model.units;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.LevelRoadPart;
class BasicUnitModel {
    var hp:Int;
    var hpMax:Int;
    var currentRoadPart:LevelRoadPart;
    public function new(hpLevel:Int, roadPart:LevelRoadPart) {
        hpMax = UnitConfig.hpByLevel[hpLevel];
        hp = hpMax;
        currentRoadPart = roadPart;
    }

    function calcDistance(other:BasicUnitModel):Int {
        return Math.round(Math.abs(this.currentRoadPart.x - other.currentRoadPart.x)) +
        Math.round(Math.abs(this.currentRoadPart.y - other.currentRoadPart.y));
    }
}
