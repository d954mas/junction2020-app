package shared.project.model.base;

import shared.base.model.BaseModelWithStorageAndData;
import shared.project.storage.Storage.StorageStruct;
class BaseProjectModelWithStorageAndData<ModelStorage, ModelData> extends
BaseModelWithStorageAndData<StorageStruct, World, ModelStorage, ModelData> {}