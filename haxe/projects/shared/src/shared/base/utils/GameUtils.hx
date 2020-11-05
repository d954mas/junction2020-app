package shared.base.utils;
import shared.project.configs.GameConfig;
import shared.project.model.World;
class GameUtils {
    public static function getSpeechBuilder(world:World):SpeechBuilder {
        if (GameConfig.PLATFORM == Platform.SBER) {
            return new SpeechBuilderSber();
        } else {
            return new SpeechBuilder();
        }
    }
}
