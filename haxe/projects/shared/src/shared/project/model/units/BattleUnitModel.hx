package shared.project.model.units;
import shared.project.enums.UnitType;
import shared.project.storage.Storage.LevelRoadPart;
class BattleUnitModel extends BasicUnitModel {
    var damage:Int;
    var attackRange:Int;
    var unitType:UnitType;

    public function canAttack(enemy:BasicUnitModel):Bool {
        return calculateDistance(enemy) <= attackRange;
    }

    public function attack(enemy:BasicUnitModel) {
        if (canAttack(enemy)) {
            enemy.takeDamage(calcDamage(enemy), this);
        }
    }

    private function calcDamage(enemy:BasicUnitModel):Int {
        var baseDmg = damage;
        return baseDmg;
    }

    public function new(hp:Int, damage:Int, attackRange:Int, roadPart:LevelRoadPart, unitType:UnitType) {
        super(hp, roadPart);
        this.unitType = unitType;
        this.damage = damage;
        this.attackRange = attackRange;
    }
}