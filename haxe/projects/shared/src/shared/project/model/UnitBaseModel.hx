package shared.project.model;
import shared.base.utils.MathUtils;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.LevelRoadPart;
import shared.project.enums.AttackType;
class UnitBaseModel {
    var hp:Int;
    var hpMax:Int;
    var currentRoadPart:LevelRoadPart;
    var attackLevel:Int;
    var defenseLevel:Int;
    var attackType:AttackType;
    var incomingDamageMultipliers:Map<AttackType, Float>;

    public function canAttack(enemy:UnitBaseModel):Bool {
        return false;
    }

    public function attack(enemy:UnitBaseModel) {
        if (canAttack(enemy)) {
            enemy.takeDamage(calcDamage(enemy), this);
        }
    }

    //source is specified for possible effects implementations - e.g. partial damage reflection
    public function takeDamage(amount:Int, source:UnitBaseModel) {
        hp = MathUtils.clamp((hp - amount), 0, hp);
    }

    private function calcDamage(enemy:UnitBaseModel):Int {
        var baseDmg = UnitConfig.attackByLevel[attackLevel];
        var enemyDamageReduction = UnitConfig.defenseByLevel[enemy.defenseLevel];
        var damageOutput = (baseDmg - enemyDamageReduction) * enemy.incomingDamageMultipliers[attackType];
        return Math.ceil(damageOutput);
    }

    public function new() {
    }
}
