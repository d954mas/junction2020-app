package shared.project.configs;
@:expose @:keep
class UnitConfig {
    public static var attackByLevel:Map<Int, Int> = [
        1 => 4,
        2 => 6,
        3 => 9,
        4 => 15,
        5 => 20
    ];
    public static var defenseByLevel:Map<Int, Int> = [
        1 => 0,
        2 => 1,
        3 => 4,
        4 => 8,
        5 => 12
    ];
}
