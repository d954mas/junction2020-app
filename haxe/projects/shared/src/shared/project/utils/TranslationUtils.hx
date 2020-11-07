package shared.project.utils;
import shared.project.enums.UnitType.MageType;
import shared.project.model.World;
import haxe.EnumTools;
class TranslationUtils {
    public static function getSpellCostMap(spellName:String, world:World) {
        var spell = MageType.getByName(spellName);
        if (spell != null) {
            return [
                spellName + "_cost" => world.levelModel.playerModel.mageGetPower(spell)
            ];
        }
        else return [];
    }
}
