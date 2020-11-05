package shared.base.model;

class BaseModelWithStorage<Storage, World:WorldBaseModel<Storage>, ModelStorage> extends BaseModel<Storage, World> {
    private var storage:ModelStorage;

    public function new(world:World, storage:ModelStorage) {
        this.storage = storage;
        super(world);
    }
}
