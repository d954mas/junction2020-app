package shared;

import haxe.Json;
import shared.project.model.World;
typedef GameConfigs = {

}


typedef GameConfigParsed = {
    config:GameConfigs
}

@:expose @:keep
class Configs {
    @:nullSafety(Off) public static var configRU:GameConfigParsed;
    @:nullSafety(Off) public static var configEN:GameConfigParsed;


    private static function parse(json:String):Dynamic {
        #if lua
        return  Reflect.callMethod(Json,Reflect.field(Json,"parseFast"),[json]);
        #else
        return Json.parse(json);
        #end
    }



    public static function getConfigByLocale(locale:String):GameConfigParsed {
        if (locale == "ru") {
            if (configRU == null) {
                configRU = parseConfig(parse(haxe.Resource.getString("game_configs_ru")));
            }
            return configRU;
        }
        if (configEN == null) {
            var data = haxe.Resource.getString("game_configs_en");
            var json = parse(data);
            configEN = parseConfig(json);
        }
        return configEN;
    }

    public static function getConfigByWorld(world:World):GameConfigParsed {
        return getConfigByLocale(world.storageGet().user.locale);
    }

    private static function parseConfig(config:GameConfigs):GameConfigParsed {
        var data:GameConfigParsed = {
            config:config,
        };


        validate(data);
        return data;
    }


    private static function validate(config:GameConfigParsed) {

    }

    //открытие героев если они закрыты, а нужный уровень пройден
    public static function checksCurrentConfigs(world:World) {
      //  checksHeroesUnlock(world);
        //skip all tutorials for now
        //  if (!world.tutorialsModel.level5Battle.isCompleted()) {
        //    world.tutorialsModel.skip(false);
        //}
    }
}
