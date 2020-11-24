package shared.project.intent_processors;
import shared.base.event.ModelEventName.EventHelper;
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
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.WIN_MODAL_RESTART:
                ask("restart");
                world.levelModel.restart();
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.HELP_MODAL_SHOW:
                world.contextChange(ContextName.HELP_MODAL);
                EventHelper.modalShow(world,"help");
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.HELP_MODAL_HIDE:
                world.contextDelete(ContextName.HELP_MODAL);
                EventHelper.modalHide(world,"help");
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.HELP_MODAL_NEXT:
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.HELP_MODAL_PREV:
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});

            case Intent.WEB_MONETIZATION_MODAL_SHOW:
                world.contextChange(ContextName.WEB_MONETIZATION_MODAL);
                EventHelper.modalShow(world,"web_monetization");
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.WEB_MONETIZATION_MODAL_HIDE:
                world.contextDelete(ContextName.WEB_MONETIZATION_MODAL);
                EventHelper.modalHide(world,"web_monetization");
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.WEB_MONETIZATION_MODAL_NEXT:
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.WEB_MONETIZATION_MODAL_PREV:
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});

            default: return null;
        }

    }
}
