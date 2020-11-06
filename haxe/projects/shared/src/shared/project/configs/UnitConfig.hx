package shared.project.configs;
@:expose @:keep
class UnitConfig {

    public static var ARCHER_ATTACK_RANGE = 2;

    public static var attackByLevel:Array<Int> = [
        4,
        6,
        9,
        15,
        20
    ];

    public static var archerAttackByLevel:Array<Int> = [
        4,
        6,
        9,
        15,
        20
    ];

/*    public static var defenseByLevel:Map<Int, Int> = [
        0,
        1,
        4,
        8,
        12
    ];*/

    public static var hpByLevel:Array<Int> = [
        20,
        30,
        40,
        80
    ];
}
