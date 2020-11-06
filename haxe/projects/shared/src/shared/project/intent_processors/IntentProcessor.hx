package shared.project.intent_processors;
import jsoni18n.I18n;
import shared.base.enums.ContextName;
import shared.base.output.ModelOutputResponse;
import shared.base.output.ModelOutputResultCode;
import shared.base.utils.GameUtils;
import shared.base.utils.SpeechBuilder;
import shared.project.analytics.AnalyticsHelper;
import shared.project.enums.Intent;
import shared.project.model.World;
import shared.Shared.OutputResponce;
class IntentProcessor {

    private var world:World;
    private var i18n:I18n;
    private var shared:Shared;
    private var processerCheats:IntentCheatsProcessor;
    private var processerModal:IntentModalProcessor;
    private var processerTutorial:IntentTutorialProcessor;
    public var speechBuilder:SpeechBuilder;

    public function new(world:World, shared:Shared, i18n:I18n) {
        this.world = world;
        this.shared = shared;
        this.i18n = i18n;
        this.speechBuilder = GameUtils.getSpeechBuilder(world);
        this.processerCheats = new IntentCheatsProcessor(this.world, this.shared, this.i18n);
        this.processerModal = new IntentModalProcessor(this.world, this.shared, this.i18n);
        this.processerTutorial = new IntentTutorialProcessor(this.world, this.shared, this.i18n);

        this.processerCheats.setBaseProcessor(this);
        this.processerModal.setBaseProcessor(this);
        this.processerTutorial.setBaseProcessor(this);
    }

    public function ask(text) {
        speechBuilder.text(text);
    }

    public function contextChange(name:ContextName, ?lifespan:Int, ?parameters:Dynamic) {
        this.world.contextChange(name, lifespan, parameters);
    }

    public function contextDelete(name:ContextName) {
        this.world.contextDelete(name);
    }

    public function contextExist(name:ContextName) {
        return this.world.contextExist(name);
    }

    public function getResult(modelResult:ModelOutputResponse) {
        return {modelResult : modelResult, events : world.eventGetAll(), analyticEvents: world.dtdAnalytics.getEvents()}
    }

    public function processIntent(intent:Intent, ?data:Dynamic):OutputResponce {
        this.speechBuilder = GameUtils.getSpeechBuilder(world);
        if (AnalyticsHelper.intentExclusions.indexOf(intent) == -1) {
            AnalyticsHelper.sendProcessIntentEvent(world, intent, data);
            AnalyticsHelper.sendPlayerInfoEvent(world);
        }
        trace("process intent:" + intent);

        if (intent != Intent.MAIN_FALLBACK && intent != Intent.MAIN_KEEP_WORKING) {

        }

        if (intent == Intent.MAIN_WELCOME) {
            ask(i18n.tr("conv/welcome"));
            AnalyticsHelper.sendGameLaunchEvent(world);
            AnalyticsHelper.sendGameSessionEvent(world);
            return getResult(this.world.outputConversationStart());
        }
        if (intent != Intent.IAP_BUY) {
            //Server was updates
            if (world.storageGet().version.version != world.storageGet().profile.currentVersion) {
                ask(i18n.tr("conv/server_was_update"));
                return getResult({code:ModelOutputResultCode.EXIT});
            }

            if (world.storageGet().profile.conversationIdCurrent != world.storageGet().profile.conversationIdAtStart) {
                ask(i18n.tr("conv/play_multiple_devices"));
                return getResult({code:ModelOutputResultCode.EXIT});
            }
        }


        var result:Null<OutputResponce> = processerCheats.processIntent(intent, data);
        if (result != null) {return result;}


        result = processerModal.processIntent(intent, data);
        if (result != null) {return result;}

        result = processerTutorial.processIntent(intent, data);
        if (result != null) {return result;}

        var storage = world.storageGet();
        switch(intent){
            //region main

            case Intent.WEBAPP_LOAD_DONE: //pass
                world.tutorialsModel.startTutorialWhenLoadGameDone();
                world.onGameLoaded();
                return getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.MAIN_KEEP_WORKING: //pass
                return getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.MAIN_FALLBACK:
                ask(i18n.tr("conv/fallback"));
                return getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.IAP_BUY:
                if (data == null) {throw "no data";}
                if (data.iapKey == null) {throw "no iap key";}
                var key = data.iapKey;
                trace("iap buy:" + key);
                return getResult({code : ModelOutputResultCode.SUCCESS});
            //endregion
            default: throw "UnknownIntent:" + intent;
        }
        throw "UnknownIntent:" + intent;
    }
}
