package shared.project.model.units;
import shared.project.storage.Storage.LevelRoadPart;
class MeleeUnitModel extends BattleUnitModel {
    public function new(hpLevel:Int, roadPart:LevelRoadPart, attackLevel:Int, defenseLevel:Int) {
        super(hpLevel, roadPart, attackLevel, defenseLevel);
    }

    override public function canAttack(enemy:BasicUnitModel) {
        return calcDistance(enemy) <= 1;
    }
}
