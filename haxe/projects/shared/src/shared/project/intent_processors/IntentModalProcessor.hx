package shared.project.intent_processors;
import shared.project.utils.SpeechWithDelaysPreductions;
import shared.base.utils.GameUtils;
import shared.project.configs.GameConfig;
import shared.base.enums.ContextName;
import shared.base.output.ModelOutputResponse;
import shared.base.output.ModelOutputResultCode;
import shared.project.enums.Intent;
import shared.Shared.OutputResponce;

class IntentModalProcessor extends IntentSubProcessor {


    public override function processIntent(intent:Intent, ?data:Dynamic):Null<OutputResponce> {
        var storage = world.storageGet();
        switch(intent){
            case Intent.LOSE_MODAL_RESTART:
                ask("restart");

                world.levelModel.restart();
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
            default: return null;
        }

    }
}
