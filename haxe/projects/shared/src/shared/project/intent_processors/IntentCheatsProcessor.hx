package shared.project.intent_processors;
import shared.base.enums.ContextName;
import shared.base.output.ModelOutputResultCode;
import shared.project.enums.Intent;
import shared.Shared.OutputResponce;

class IntentCheatsProcessor extends IntentSubProcessor {

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
            case Intent.CHEATS_MONEY_ADD:
                ask(i18n.tr("add money"));
                world.levelModel.playerModel.moneyChange(100,"Cheats");
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
            case Intent.CHEATS_MANA_ADD:
                ask(i18n.tr("add mana"));
                world.levelModel.playerModel.manaChange(100,"Cheats");
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
            case Intent.CHEATS_RESTORE_HP:
                ask(i18n.tr("restore hp"));
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
            case Intent.CHEATS_KILL_ALL_ENEMIES:
                ask(i18n.tr("kill all enemies"));
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
            case Intent.WEB_MONETIZATION_DEBUG_ENABLE:
                world.storageGet().profile.webMonetization = true;
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
            case Intent.WEB_MONETIZATION_DEBUG_DISABLE:
                world.storageGet().profile.webMonetization = false;
                return baseProcessor.getResult( {code : ModelOutputResultCode.SUCCESS});
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
