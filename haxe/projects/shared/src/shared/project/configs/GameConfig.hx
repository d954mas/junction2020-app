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
    public static final MAX_MANA:Int = 100;
#end
}



typedef INITIAL_VALUES = {

}