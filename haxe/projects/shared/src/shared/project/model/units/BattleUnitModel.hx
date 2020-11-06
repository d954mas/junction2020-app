package shared.project.model.units;
import shared.project.configs.UnitConfig;

import shared.base.utils.MathUtils;
import shared.project.storage.Storage.BattleUnitStruct;

class BattleUnitModel {
    private var struct:BattleUnitStruct;
    public function canAttack(enemy:BattleUnitModel):Bool {
        return calculateDistance(enemy) <= struct.attackRange;
    }

    public function attack(enemy:BattleUnitModel) {
        if (canAttack(enemy)) {
            enemy.takeDamage(calcDamage(enemy), this);
        }
    }

    private function calcDamage(enemy:BattleUnitModel):Int {
        @:nullSafety(Off) var baseDmg = getScales().attackByLevel[struct.attackLvl - 1];
        return baseDmg;
    }

    public function new(struct:BattleUnitStruct) {
        this.struct = struct;
    }

    function calculateDistance(other:BattleUnitModel):Int {
        return Math.round(Math.abs(struct.roadPart.x - other.struct.roadPart.x)) +
        Math.round(Math.abs(struct.roadPart.y - struct.roadPart.y));
    }

    //source is specified for possible effects implementations - e.g. partial damage reflection
    public function takeDamage(amount:Int, source:BattleUnitModel) {
        struct.hp = Math.round(MathUtils.clamp((struct.hp - amount), 0, struct.hp));
    }

    public function isAlive() {
        return struct.hp > 0;
    }

    public function takeHealing(amount:Int) {
        struct.hp = Math.round(MathUtils.clamp((struct.hp + amount), 0, struct.hp));
    }

    public function getReward() {
        @:nullSafety(Off) return getScales().rewardByLevel[struct.hpLvl];
    }

    private function getScales() {
        return UnitConfig.scalesByUnitType[struct.type];
    }
}