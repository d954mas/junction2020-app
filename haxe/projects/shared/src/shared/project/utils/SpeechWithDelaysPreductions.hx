package shared.project.utils;
import shared.project.configs.GameConfig;
import shared.project.model.World;


typedef SpeechDelays = {

}

typedef SoundTypedef = {
    time:Float,
    name:String
}

typedef AllSounds = {


}


class SpeechWithDelaysPreductions {
    private static var URL_SOUNDS = "https://junction2020-prod.firebaseapp.com/static/sounds/";
    private static var sounds:AllSounds = {
    }

    private static var ruDelays:SpeechDelays = {

    }

    private static var enDelays:SpeechDelays = {

    }

    private static function getDelays(world:World):SpeechDelays {
        if (world.storageGet().user.locale == "ru") {
            return ruDelays;
        }
        return enDelays;
    }

    public static function getSounds(world:World):AllSounds{
        return sounds;
    }

    public static function getSound(world:World, name:String):String {
        if (GameConfig.PLATFORM == Platform.SBER) {
            return  name;
        } else {
            return URL_SOUNDS + name;
        }
    }
}
