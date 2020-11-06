package shared.project.model.units;
import shared.project.enums.AttackType;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.LevelRoadPart;
class ArcherUnitModel extends BattleUnitModel {
    public function new(hpLevel:Int, roadPart:LevelRoadPart, attackLevel:Int, defenseLevel:Int) {
        super(hpLevel, roadPart, attackLevel, defenseLevel);
        attackScale = UnitConfig.archerAttackByLevel;
    }

    override public function canAttack(enemy:BasicUnitModel):Bool {
        return calcDistance(enemy) <= UnitConfig.ARCHER_ATTACK_RANGE;
    }
}
