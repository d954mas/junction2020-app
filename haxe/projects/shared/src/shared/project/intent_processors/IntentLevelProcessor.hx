package shared.project.intent_processors;
import shared.base.enums.ContextName;
import shared.base.output.ModelOutputResultCode;
import shared.project.enums.Intent;
import shared.Shared.OutputResponce;

class IntentLevelProcessor extends IntentSubProcessor {

    public override function processIntent(intent:Intent, ?data:Dynamic):Null<OutputResponce> {
        var storage = world.storageGet();
        switch(intent){
            case Intent.DEBUG_TOGGLE:
            //TODO: check if user is allowed to turn on debug
                Assert.assert(world.isDev(), "cheats only work in dev mode");
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.CHEATS_ENABLE:
                var modelResult = this.world.outputCheatsEnable();
                ask(i18n.tr("conv/cheats_enabled"));
                return baseProcessor.getResult(modelResult);
            case Intent.CHEATS_DISABLE:
                var modelResult = this.world.outputCheatsDisable();
                ask(i18n.tr("conv/cheats_disabled"));
                return baseProcessor.getResult(modelResult);
            default: return null;
        }
        throw "no return for intent:" + intent;
    }

    private function checkCheats() {
        try {
            Assert.assert(world.isCheatsEnabled(), "cheats not enabled");
        } catch(e:Any) {
            world.contextDelete(ContextName.CHEATS);
            world.storageGet().profile.cheatsEnabled = false;
            throw e;
        }
    }
}
