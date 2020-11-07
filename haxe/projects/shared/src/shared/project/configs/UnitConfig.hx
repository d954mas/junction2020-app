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
        hpByLevel: [50, 50, 50, 50, 50],
        attackByLevel: [1, 1, 1, 1, 1],
        attackRange: 1,
        costByLevel: [0, 0, 0, 0, 0],
        rewardByLevel: [0, 0, 0, 0, 0]
    }
    ];

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
