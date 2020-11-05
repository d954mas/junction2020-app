package shared.base.model;

import shared.base.enums.ContextName;
import shared.base.event.ModelEvent;
import shared.base.event.ModelEventName;
import shared.base.struct.ContextStruct;
import shared.project.enums.Intent;


class WorldBaseModel<Storage> {
    private var storage:Storage;
    private var contexts:Map<ContextName, ContextStruct>;
    private var events:Array<ModelEvent>;
    public var intent:Intent;

    public function new(storage:Storage) {
        this.storage = storage;
        contexts = new Map<ContextName, ContextStruct>();
        events = new Array();
        intent = Intent.MAIN_FALLBACK;
    }

    public function restore():Void {}

    //region context
    public function contextExist(ctx:ContextName):Bool {
        var data:Null<ContextStruct> = contexts.get(ctx);
        if (data == null) {return false;}
        else {
            return true;
            // return data.lifespan >= 0;
        }
    }

    public function contextExistNotEmpty(ctx:ContextName):Bool {
        var data:Null<ContextStruct> = contexts.get(ctx);
        if (data == null) {return false;}
        else {
            return data.lifespan > 0;
        }
    }

    public function contextGet(ctx:ContextName):Null<ContextStruct> {
        return contexts.get(ctx);
    }

    public function contextGetAll():Array<ContextStruct> {
        var result:Array<ContextStruct> = new Array();
        for (context in this.contexts) {
            result.push(context);
        }
        return result;
    }

    public function contextsGet():Map<ContextName, ContextStruct> {
        return contexts;
    }

    public function contextInit(map:Map<ContextName, ContextStruct>) {
        contexts = map;
    }


    public function contextChange(name:ContextName, lifespan:Int = 99999, ?parameters:Dynamic) {
        this.contexts.set(name, new ContextStruct(name, lifespan, parameters));
    }

    public function contextDelete(name:ContextName) {
        this.contextChange(name, 0, null);
    }

    public function contextDeleteAll() {
        for (ctx in contextGetAll()) {
            contextDelete(ctx.name);
        }
    }
    //endregion

    //region storage
    public function storageInit(storage:Storage) {this.storage = storage;}

    public function storageGet():Storage {return storage;}


    public function storageOutputGet():Storage {
        return storageGet();
    }
    //endregion
    //region event
    public function eventClear() {events = new Array();}

    public function eventEmit(name:ModelEventName, ?data:Dynamic) {events.push({name:name, data:data});}
    public function eventGetAll():Array<ModelEvent> {return events;}
    public function eventExist(name:ModelEventName):Array<ModelEvent> {
        return events;
    }
    //endregion
}
