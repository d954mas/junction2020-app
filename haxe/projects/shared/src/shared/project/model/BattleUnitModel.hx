package shared.project.model;
import shared.base.utils.MathUtils;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.LevelRoadPart;
import shared.project.enums.AttackType;
class BattleUnitModel extends BasicUnitModel {
    var attackLevel:Int;
    //var defenseLevel:Int;
    var attackType:AttackType;
    //var incomingDamageMultipliers:Map<AttackType, Float>;

    public function canAttack(enemy:BattleUnitModel):Bool {
        return false;
    }

    public function attack(enemy:BattleUnitModel) {
        if (canAttack(enemy)) {
            enemy.takeDamage(calcDamage(enemy), this);
        }
    }

    //source is specified for possible effects implementations - e.g. partial damage reflection
    public function takeDamage(amount:Int, source:BattleUnitModel) {
        hp = MathUtils.clamp((hp - amount), 0, hp);
    }

    private function calcDamage(enemy:BattleUnitModel):Int {
        var baseDmg = UnitConfig.attackByLevel[attackLevel];
        //var enemyDamageReduction = UnitConfig.defenseByLevel[enemy.defenseLevel];
        //var damageOutput = (baseDmg - enemyDamageReduction) * enemy.incomingDamageMultipliers[attackType];
        return baseDmg;
    }

    public function new(hpLevel:Int, roadPart:LevelRoadPart, attackLevel:Int, defenseLevel:Int) {
        super(hpLevel, roadPart);
        this.attackLevel = attackLevel;
        //this.defenseLevel = defenseLevel;
    }
}
