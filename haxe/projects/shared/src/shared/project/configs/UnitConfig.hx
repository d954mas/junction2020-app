package shared.project.configs;
import shared.project.enums.UnitType;
@:expose @:keep
typedef UnitScales = {
var hpByLevel:Array<Int>;
var attackByLevel:Array<Int>;
var attackRange:Int;
};
class UnitConfig {

    public static var scalesByUnitType:haxe.ds.Map<UnitType, Dynamic> = [
        UnitType.ARCHER => {
            hpByLevel: [5, 10, 15, 20, 25],
            attackByLevel: [2, 4, 6, 8, 10],
            attackRange: 2
        },
        UnitType.KNIGHT => {
            hpByLevel: [5, 10, 15, 20, 25],
            attackByLevel: [4, 8, 12, 16, 20],
            attackRange: 1
        }
    ];
}
