package shared.project.configs;
import shared.project.enums.UnitType;
@:expose @:keep
typedef UnitScales = {
var hpByLevel:Array<Int>;
var attackByLevel:Array<Int>;
var attackRange:Int;
var rewardByLevel:Array<Int>;
var costByLevel:Array<Int>;
};
class UnitConfig {
    public static var scalesByUnitType:haxe.ds.Map<UnitType, UnitScales> = [
        UnitType.KNIGHT => {
        hpByLevel: [2, 2, 2, 2, 2],
        attackByLevel: [2, 2, 2, 2, 2],
        attackRange: 1,
        costByLevel: [100, 100, 100, 100, 100],
        rewardByLevel: [50, 50, 50, 50, 50]

    },
        UnitType.ARCHER => {
        hpByLevel: [2, 2, 2, 2, 2],
        attackByLevel: [1, 1, 1, 1, 1],
        attackRange: 2,
        costByLevel: [125, 125, 125, 125, 125],
        rewardByLevel: [75, 75, 75, 75, 75]
    },
        UnitType.SHIELD => {
        hpByLevel: [4, 4, 4, 4, 4],
        attackByLevel: [2, 2, 2, 2, 2],
        attackRange: 1,
        costByLevel: [200, 200, 200, 200, 200],
        rewardByLevel: [100, 100, 100, 100, 100]
    },
        UnitType.SPEARMAN => {
        hpByLevel: [3, 3, 3, 3, 3],
        attackByLevel: [2, 2, 2, 2, 2],
        attackRange: 1,
        costByLevel: [250, 250, 250, 250, 250],
        rewardByLevel: [150, 150, 150, 150, 150]
    },
        UnitType.MAGE => {
        hpByLevel: [4, 4, 4, 4, 4],
        attackByLevel: [3, 3, 3, 3, 3],
        attackRange: 2,
        costByLevel: [400, 400, 400, 400, 400],
        rewardByLevel: [250, 250, 250, 250, 250]
    },
        UnitType.CASTLE => {
        hpByLevel: [20, 20, 20, 20, 20],
        attackByLevel: [1, 1, 1, 1, 1],
        attackRange: 1,
        costByLevel: [0, 0, 0, 0, 0],
        rewardByLevel: [0, 0, 0, 0, 0]
    }
    ];

    public static var resourceScale = [10, 20, 40, 50, 60];

    public static function unitTypeGetById(id:String):Null<UnitType> {
        if (id == Std.string(UnitType.ARCHER)) {return UnitType.ARCHER;}
        else if (id == Std.string(UnitType.KNIGHT)) {return UnitType.KNIGHT;}
        else if (id == Std.string(UnitType.SHIELD)) {return UnitType.SHIELD;}
        else if (id == Std.string(UnitType.SPEARMAN)) {return UnitType.SPEARMAN;}
        else if (id == Std.string(UnitType.MAGE)) {return UnitType.MAGE;}
        else if (id == Std.string(UnitType.CASTLE)) {return UnitType.CASTLE;}


        return null;
    }
}

typedef MageScales = {
var costByLevel:Array<Int>;
var powerByLevel:Array<Int>;
var power2ByLevel:Array<Int>;
};

class MageConfig {
    public static var scalesByMageType:haxe.ds.Map<MageType, MageScales> = [
        MageType.FIREBALL => {
        costByLevel: [0, 90, 90, 90, 90],
        powerByLevel: [1, 1, 1, 1, 1],
        power2ByLevel: [0, 0, 0, 0, 0],
    },
        MageType.ICE => {
        costByLevel: [0, 150, 150, 150, 150],
        powerByLevel: [2, 2, 2, 2, 2],
        power2ByLevel: [0, 0, 0, 0, 0],
    },
        MageType.CARAVAN => {
        costByLevel: [100, 150, 200, 999],
        powerByLevel: [1, 2, 3, 4],
        power2ByLevel: [0, 0, 0, 0, 0],
    },
        MageType.MANA => {
        costByLevel: [75, 90, 150, 999],
        powerByLevel: [15, 20, 30, 40, 2],
        power2ByLevel: [100, 125, 150, 200, 250],
    },
    ];

    public static function mageTypeGetById(id:String):Null<MageType> {
        if (id == Std.string(MageType.FIREBALL)) {return MageType.FIREBALL;}
        else if (id == Std.string(MageType.ICE)) {return MageType.ICE;}
        else if (id == Std.string(MageType.CARAVAN)) {return MageType.CARAVAN;}
        else if (id == Std.string(MageType.MANA)) {return MageType.MANA;}


        return null;
    }
}
