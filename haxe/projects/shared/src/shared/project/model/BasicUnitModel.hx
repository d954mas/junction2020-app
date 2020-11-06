package shared.project.model;
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
}
