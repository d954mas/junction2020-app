package shared.project.model.units;
import shared.project.storage.Storage.BasicUnitStruct;

class BasicUnitModel {
    //var world:World;
    var unitStruct:BasicUnitStruct;
    public function new(struct:BasicUnitStruct) {
        //this.world = world;
        this.unitStruct = struct;
    }
}
