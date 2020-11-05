package shared.base.model;

class BaseModelWithStorageAndData<Storage, World:WorldBaseModel<Storage>, ModelStorage, ModelData>
extends BaseModelWithStorage<Storage, World, ModelStorage> {

    private var data:Null<ModelData>;

    public function new(world:World, storage:ModelStorage, ?data:ModelData) {
        super(world, storage);
        if (data != null) {
            modelDataSet(data);
        }
    }

    //region modalData
    public function modelDataSet(data:ModelData) {
        Assert.assert(data != null, "data can't be null");
        this.data = data;
        modelDataChanged();
    }

    private function modelDataChanged() {}

    public function modelDataIsHave():Bool {return data != null;}

    public function modelDataGet():Null<ModelData> {
        return data;
    }
    //endregion
}
