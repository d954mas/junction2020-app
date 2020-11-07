package shared.project.enums;
enum abstract UnitType(String) {
    var KNIGHT;
    var ARCHER;
    var SHIELD;
    var SPEARMAN;
    var MAGE;
    var CASTLE;
    public static var ALL_TYPES = [KNIGHT, ARCHER, SHIELD, SPEARMAN, MAGE, CASTLE];
}


enum abstract MageType(String) {
    var FIREBALL;
    var ICE;
    public static var ALL_TYPES = [FIREBALL, ICE];
}