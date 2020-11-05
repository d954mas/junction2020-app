package shared.base;

import haxe.DynamicAccess;
import haxe.Json;
import shared.project.enums.Intent;
import shared.project.model.World;
typedef SpeechCommandData = {
    var intent:String;
    var regexp:EReg;
    var order:Int;
}

typedef SpeechCommandJsonData = {
    var text:String;
    var order:Int;
}

@:expose @:keep
class SpeechCommands {
    @:nullSafety(Off) private static var eng:Array<SpeechCommandData>;
    @:nullSafety(Off) private static var ru:Array<SpeechCommandData>;

    @:nullSafety(Off)
    private static function parseCommands(str:String):Array<SpeechCommandData> {
        var result:Array<SpeechCommandData> = new Array();
        //в луа не добавлены регулярки
        #if lua

        #else
        var jsonData:DynamicAccess<SpeechCommandJsonData> = Json.parse(str);
        if (jsonData == null) {
            throw "json not valid";
        }
        for (kv in jsonData.keyValueIterator()) {
            var regexp = new EReg(kv.value.text, "");
            var intent = kv.key;
            Assert.assert(Intents.isIntent(cast intent), "unknown intent:" + intent);
            result.push({regexp:regexp, intent:intent, order:kv.value.order});
        }
        #end

        result.sort(function(a:SpeechCommandData, b:SpeechCommandData):Int {
            if (a.order > b.order) {return -1;}
            else if (a.order < b.order) {return 1;}
            else {return 0;}
        });

        return result;
    }

    public static function checkIntent(world:World, query:String):Null<Intent> {
        query = query.toLowerCase();
        query = StringTools.trim(query);
        var array:Array<SpeechCommandData> = getForLocale(world.storageGet().user.locale);

        for (data in array) {
            if (world.canProcessIntent(cast data.intent, null, false) && data.regexp.match(query)) {
                return cast data.intent;
            }
        }
        return null;
    }

    private static function getForLocale(locale:String):Array<SpeechCommandData> {
        if (locale == "ru") {
            return ru;
        } else {
            return eng;
        }
    }

    public static function load() {
        ru = parseCommands(haxe.Resource.getString("speech_commands_ru"));
        eng = parseCommands(haxe.Resource.getString("speech_commands_en"));
    }
}
