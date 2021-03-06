package shared.project.model.units;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.storage.Storage.LevelRoadPart;
import shared.project.configs.UnitConfig;

import shared.base.utils.MathUtils;
import shared.project.storage.Storage.BattleUnitStruct;
@:expose @:keep
class BattleUnitModel implements IBattleUnit {
    private var struct:BattleUnitStruct;
    private var world:World;

    public function canAttack(enemy:IBattleUnit):Bool {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for canMove";}
        if(getOwnerId()>0 && level.ice>0){return false;}
        return calculateDistance(enemy) <= struct.attackRange && (getOwnerId() != enemy.getOwnerId());
    }

    public function attack(enemy:IBattleUnit):Void {
        if (canAttack(enemy)) {
            var damage = calcDamage(enemy);
            enemy.takeDamage(calcDamage(enemy));
            EventHelper.levelUnitAttack(world, getId(), enemy.getId());
            EventHelper.levelUnitTakeDamage(world,enemy.getId(),damage,"attack", getId());

        }
    }

    //enemy is passed in case of addition of damage-reducing effects
    private function calcDamage(enemy:IBattleUnit):Int {
        @:nullSafety(Off) var baseDmg = getScales().attackByLevel[struct.attackLvl];
        return baseDmg;
    }

    public function new(struct:BattleUnitStruct, world:World) {
        this.struct = struct;
        this.world = world;
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
        return world.levelModel.roadsFindPartById(struct.roadPartIdx);
    }

    public function canMove():Bool {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for canMove";}
        if(getOwnerId()>0 && level.ice>0){return false;}
        return true;
    }

    public function move(roadPartIdx:Int):Void {
        struct.roadPartIdx = roadPartIdx;
        EventHelper.levelUnitMove(world, getId(), roadPartIdx);
    }

    public function getOwnerId() {
        return struct.ownerId;
    }

    public function getType() {
        return struct.type;
    }

    public function getId() {
        return struct.id;
    }

    public function getStruct() {
        return struct;
    }
    public function getHp() {
        return struct.hp;
    }
    public function getMaxHp() {
        @:nullSafety(Off) var baseDmg = getScales().hpByLevel[struct.attackLvl];
        return baseDmg;
    }

    public function getAttack() {
        var scales = getScales();
        if (scales == null) {throw "no scales in getAttack";}
        return scales.attackByLevel[struct.attackLvl];
    }
}