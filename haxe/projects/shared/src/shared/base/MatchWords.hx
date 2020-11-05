package shared.base;

import haxe.DynamicAccess;
import haxe.Json;
import shared.project.enums.Intent;
import shared.project.model.World;


@:expose @:keep
class MatchWords {
    @:nullSafety(Off) private static var eng:Array<String>;
    @:nullSafety(Off) private static var ru:Array<String>;

    @:nullSafety(Off)
    private static function parse(str:String):Array<String> {
        var result:Array<String> = new Array();
        var jsonData:DynamicAccess<Array<String>> = Json.parse(str);
        if (jsonData == null) {
            trace(str);
            throw "json not valid";
        }
        for (kv in jsonData.keyValueIterator()) {
            var intent = kv.key;
            Assert.assert(Intents.isIntent(cast intent), "unknown intent:" + intent);
            var list = kv.value;
            for (word in list) {
                result.push(word);
            }
        }

        return result;
    }


    private static function getForLocale(locale:String):Array<String> {
        if (locale == "ru") {
            return ru;
        } else {
            return eng;
        }
    }

    public static function getForWorld(world:World):Array<String> {
        return getForLocale(world.storageGet().user.locale);
    }


    public static function load() {
        ru = parse(haxe.Resource.getString("match_words_ru"));
        eng = parse(haxe.Resource.getString("match_words_en"));
        trace(ru);
        trace(eng);
    }
}
