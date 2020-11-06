package shared.project.model.units;
import shared.base.utils.MathUtils;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.LevelRoadPart;
class BasicUnitModel {
    var hp:Int;
    var hpMax:Int;
    var currentRoadPart:LevelRoadPart;
    public function new(hp:Int, roadPart:LevelRoadPart) {
        hpMax = hp;
        this.hp = hp;
        currentRoadPart = roadPart;
    }

    function calculateDistance(other:BasicUnitModel):Int {
        return Math.round(Math.abs(this.currentRoadPart.x - other.currentRoadPart.x)) +
        Math.round(Math.abs(this.currentRoadPart.y - other.currentRoadPart.y));
    }


    //source is specified for possible effects implementations - e.g. partial damage reflection
    public function takeDamage(amount:Int, source:BattleUnitModel) {
        hp = MathUtils.clamp((hp - amount), 0, hp);
    }
}
