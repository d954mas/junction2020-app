package ;

import haxe.Json;
import shared.project.storage.Storage.StorageStruct;
import shared.base.struct.ContextStruct;
import haxe.Json;
import shared.base.struct.ContextStruct;
import shared.base.enums.ContextName;
import utest.Assert;
import shared.base.NativeApi;
import shared.Shared;


class FakeConversationNativeApi implements NativeApi {
    var conv:FakeConversation;
    var contexts:Array<ContextStruct>;

    public function new(conv:FakeConversation) {
        this.conv = conv;
        this.contexts = new Array();
    }

    public function clear() {
        contexts = new Array();
    }

    public function convExit() {
        conv.exit = true;
        conv.resultStruct = null;
        conv.result = "";
    }


    public function saveStorage(storageJson:String):Void {
        this.conv.storageJson = storageJson;
        this.conv.storage = Json.parse(storageJson);
    }

    public function contextSet(name:ContextName, lifespan:Int, parameters:Null<Dynamic>):Void {
        contexts.push(new ContextStruct(name, lifespan, parameters));
    }

    public function convAskHtmlResponse(dataJson:String):Void {
        conv.result = dataJson;
        conv.resultStruct = Json.parse(dataJson);
    }

    public function convAsk(text:String):Void {

    }

    public function flushDone():Void {
        conv.contextsJson = Json.stringify(contexts);
        clear();
    }

}

class FakeConversation {
    public var storageJson:String;
    public var storage:StorageStruct;
    public var contextsJson:String;
    public var result:String;
    public var resultStruct:OutputStruct;
    public var native:FakeConversationNativeApi;
    public var exit:Bool = false;

    public function new() {
        native = new FakeConversationNativeApi(this);
        clear();
    }

    public function clear() {
        exit = false;
        this.native.clear();
        var locale = "eng";
        #if locale_ru
            var locale = "ru";
        #end
        this.storageJson = Json.stringify({user:{locale:locale}, testData : {baseWord : "achievement"}, profile:{uuid:"test_UUID"}});
        this.contextsJson = Json.stringify({});
        this.result = "";
    }

    public function setStorage(storageJson:String) {
        this.storageJson = storageJson;
        this.storage = Json.parse(storageJson);
    }

    public function storageStructUpdated() {
        this.storageJson = Json.stringify(this.storage);
    }

    public function storageSaveResultToStorage() {
        this.storageJson = this.result;
        this.storage = this.resultStruct.storage;
    }

    public function setContexts(contextsJson:String) {
        this.contextsJson = contextsJson;
    }

    public function getShared(initClientStorage = false):Shared {
        Assert.notNull(storageJson);
        Assert.notNull(contextsJson);
        var shared = new Shared(native, storageJson, contextsJson, initClientStorage,true);
        shared.world.storageGet().version = {
            version:"0",
            time:0,
            server:"dev",
        }
        shared.updateServerTime();
        return shared;
    }
}
