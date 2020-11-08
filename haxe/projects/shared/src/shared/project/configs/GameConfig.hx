package shared.project.configs;
import seedyrng.Random;

@:expose @:keep
enum abstract Platform(String) {
    var SBER = "sber";
    var GOOGLE = "google";
}

@:expose @:keep
class GameConfig {
    public static var RANDOM:Random = new Random();

    public static final INITIAL_VALUES:INITIAL_VALUES = {
    };
#if (speech_platform == "sber")
     public static final PLATFORM:Platform = Platform.SBER;
#else
    public static final PLATFORM:Platform = Platform.GOOGLE;
    //Как станет понятнее, прокачивается или нет можно поправить
    public static final START_MANA:Int = 60;
    public static final START_MONEY:Int = 150;

    public static final MONEY_REGEN:Int = 30;
    public static final MANA_REGEN:Int = 10;
#end
}



typedef INITIAL_VALUES = {

}