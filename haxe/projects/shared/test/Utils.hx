package ;
import shared.Shared;
import haxe.DynamicAccess;
import haxe.CallStack;
import haxe.PosInfos;
import shared.project.enums.Intent;
import shared.project.utils.TimeUtils;
import shared.base.event.ModelEvent;
import shared.base.event.ModelEventName;
import utest.Assert;
import shared.base.output.ModelOutputResultCode;
class Utils {
    public function new() {
    }

    //skip tutorial levels.
    public static function prepare(conv:FakeConversation):Shared {
        conv.clear();
        var shared:Shared = conv.getShared();
        shared.world.tutorialsModel.skip();
        shared.processIntent(Intent.MAIN_WELCOME);
        conv.storageStructUpdated();
        return shared;
    }


    public static function prepareNewUser(conv:FakeConversation):Shared {
        conv.clear();
        var shared:Shared = conv.getShared();
        shared.processIntent(Intent.MAIN_WELCOME);
        conv.storageStructUpdated();
        return shared;
    }


    //delta between time is 0 or 1.
    public static function timeEqual(time1:Float, ?time2:Float):Bool {
        if (time2 == null) {time2 = TimeUtils.getCurrentTime();}
        return 1 >= (time1 - time2);
    }


    public static function assertResultIntentEquals(conv:FakeConversation, intent:Intent, ?infos:haxe.PosInfos) {
        Assert.equals(intent, conv.resultStruct.intent, infos);
    }

    public static function assertResultCodeEquals(conv:FakeConversation, code:ModelOutputResultCode = ModelOutputResultCode.SUCCESS, ?infos:haxe.PosInfos) {
        Assert.equals(code, conv.resultStruct.response.modelResult.code, null, infos);
        if (conv.resultStruct.response.modelResult.code != code) {
            trace('Assert at ${infos.fileName}:${infos.lineNumber}');
            trace("Error.Need:" + code + " get:" + conv.resultStruct.response.modelResult.code);
            trace(conv.resultStruct);
        }
    }

    public static function assertResultCode(conv:FakeConversation, code:ModelOutputResultCode,data:Null<Dynamic>, ?infos:haxe.PosInfos) {
        if (conv.resultStruct.response.modelResult.code != code) {
            trace("Except:"+ code +" Get:" + conv.resultStruct.response.modelResult.code);
            trace(conv.resultStruct);
        } else if (data != null) {
            Assert.equals(data, conv.resultStruct.response.modelResult.data, infos);
            if (conv.resultStruct.response.modelResult.data != data) {
                trace("Error.Data not equals.Need:" + data + " Get:" + conv.resultStruct.response.modelResult.data);
            }
        }
    }

    public static function convGetEventFirst(conv:FakeConversation, event:ModelEventName):ModelEvent {
        var events = conv.resultStruct.response.events;
        for (resultEvent in events) {
            if (resultEvent.name == event) {
                return resultEvent;
            }
        }
        return null;
    }

    public static function assertResultCodeError(conv:FakeConversation, data:Null<Dynamic>, ?infos:haxe.PosInfos) {
        Assert.equals(ModelOutputResultCode.ERROR, conv.resultStruct.response.modelResult.code, infos);

        if (conv.resultStruct.response.modelResult.code != ModelOutputResultCode.ERROR) {
            trace("Except error. Get:" + conv.resultStruct.response.modelResult.code);
            trace(conv.resultStruct);
        } else if (data != null) {
            Assert.equals(conv.resultStruct.response.modelResult.data, data, infos);
            if (conv.resultStruct.response.modelResult.data != data) {
                trace("Error.Data not equals.Need:" + data + " Get:" + conv.resultStruct.response.modelResult.data);
            }
        }
    }

    public static function mapToString<VALUE>(map:Map<String, VALUE>):String {
        var keys:Array<String> = new Array();
        for (k in map.keys()) {
            keys.push(k);
        }
        keys.sort(function(a:String, b:String):Int {
            if (a < b) {return -1;}
            else if (a > b) {return 1;}
            else {return 0;}
        });
        var result:String = "{";
        for (key in keys) {
            result = result + key + " => " + map.get(key) + ", ";
        }
        result = result.substring(0, result.length - 2) + "}";
        return result;
    }

    public static function arrayToString<DATA>(array:Array<DATA>):String {
        var result:String = "[";
        for (data in array) {
            result = result + data + ", ";
        }
        result = result.substring(0, result.length - 2) + "]";
        return result;
    }

    public static function here(?pos:haxe.PosInfos):haxe.PosInfos return pos;
}
