package shared.base.model;
//model handle all it data in storage
//model can restore it state from storage.For example unit
//can get it prototype by id from storage
class BaseModel<Storage, World:WorldBaseModel<Storage> > {
    private var world:World;
    private var ds:Storage;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
    }

    public function modelRestore():Void {
    }
}
