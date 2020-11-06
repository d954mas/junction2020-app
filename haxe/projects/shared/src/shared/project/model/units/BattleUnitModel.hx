package shared.project.model.units;
import shared.project.storage.Storage.LevelRoadPart;
import shared.project.configs.UnitConfig;

import shared.base.utils.MathUtils;
import shared.project.storage.Storage.BattleUnitStruct;

class BattleUnitModel implements IBattleUnit {
    private var struct:BattleUnitStruct;
    public function canAttack(enemy:IBattleUnit):Bool {
        return calculateDistance(enemy) <= struct.attackRange && (getOwnerId() != enemy.getOwnerId());
    }

    public function attack(enemy:IBattleUnit):Void {
        if (canAttack(enemy)) {
            enemy.takeDamage(calcDamage(enemy));
        }
    }

    //enemy is passed in case of addition of damage-reducing effects
    private function calcDamage(enemy:IBattleUnit):Int {
        @:nullSafety(Off) var baseDmg = getScales().attackByLevel[struct.attackLvl - 1];
        return baseDmg;
    }

    public function new(struct:BattleUnitStruct) {
        this.struct = struct;
    }

    function calculateDistance(other:IBattleUnit):Int {
        return Math.round(Math.abs(getPos().x - other.getPos().x)) +
        Math.round(Math.abs(getPos().y - other.getPos().y));
    }

    public function takeDamage(amount:Int) {
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

    public function getPos():LevelRoadPart {
        return struct.roadPart;
    }

    public function canMove():Bool {
        return true;
    }

    public function move(newPos:LevelRoadPart):Void {
        struct.roadPart = newPos;
    }

    public function getOwnerId() {
        return struct.ownerId;
    }
}