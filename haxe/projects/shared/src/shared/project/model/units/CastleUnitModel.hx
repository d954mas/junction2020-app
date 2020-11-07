package shared.project.model.units;
import shared.base.event.ModelEventName.EventHelper;
import shared.base.utils.MathUtils;
import shared.project.configs.UnitConfig;
import shared.project.storage.Storage.BattleUnitStruct;
import shared.project.storage.Storage.LevelRoadPart;
@:expose @:keep
class CastleUnitModel extends BattleUnitModel {

    public override function canMove():Bool {
        return false;
    }

    override public function getStruct() {
        return struct;
    }

}