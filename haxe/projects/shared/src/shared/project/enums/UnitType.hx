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
