package shared;

import haxe.Json;
import jsoni18n.I18n;
import Array;
import shared.base.enums.ContextName;
import shared.base.event.ModelEvent;
import shared.base.Localization;
import shared.base.MatchWords;
import shared.base.NativeApi;
import shared.base.output.ModelOutputResponse;
import shared.base.output.ModelOutputResultCode;
import shared.base.SpeechCommands;
import shared.base.struct.ContextStruct;
import shared.base.utils.GameUtils;
import shared.base.utils.SpeechBuilder;
import shared.project.analytics.AnalyticsHelper;
import shared.project.analytics.DtdAnalytics;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
import shared.project.enums.Intent;
import shared.project.intent_processors.IntentProcessor;
import shared.project.model.Restrictions;
import shared.project.model.World;
import shared.project.storage.Storage;
import shared.project.utils.SpeechWithDelaysPreductions;
import shared.project.utils.TimeUtils;

@:expose @:keep class Shared {

    private var nativeApi:NativeApi;
    private var i18n:I18n;

    public var world:World;
    private var intentProcessor:IntentProcessor;

    private var dsBackupJson:String;

    public function new(nativeApi:NativeApi, storageJson:String, contextsJson:String, initClientStorage = false, isDev = false) {
        this.nativeApi = nativeApi;

        dsBackupJson = storageJson;
        var storage:StorageStruct = Storage.restore(storageJson);
        if (initClientStorage) {
            Storage.initClientStruct(storage);
        }
        world = new World(storage);

        i18n = Localization.getI18n(world.storageGet().user.locale);

        world.setI18n(i18n);
        world.isDevServer = isDev;
        intentProcessor = new IntentProcessor(world, this, i18n);
        world.setIntentProcessor(intentProcessor);
        contextInit(contextsJson);
        Configs.checksCurrentConfigs(world);
    }

    public function isDevUser():Bool{
        return world.isDevUser();
    }

    public function setConversationID(id:String) {
        world.storageGet().profile.conversationIdCurrent = id;
    }

    public function setUUID(uuid:String) {
        world.storageGet().profile.uuid = uuid;
    }

    public function setClientIntentIdx(idx:Int) {
        trace("setClientIntentIdx:" + idx);
        world.clientIntentIdx = idx;
    }


    public function storageInit(storageJson:String) {
        dsBackupJson = storageJson;
        world.storageInit(Storage.restore(storageJson));
    }

    public function contextInit(contextsJson:String) {
        world.contextInit(ContextJsonToMap(contextsJson));
    }

    public static function ContextJsonToMap(contextsJson:String) {
        var contextsData:Dynamic = haxe.Json.parse(contextsJson);

        var contexts:Array<ContextStruct> = new Array();
        var i = 0;
        while (contextsJson != "" && contextsJson != "{}") {
            var context:Dynamic = contextsData[i];
            if (context == null) {break;}
            var lifespan:Null<Int> = context.lifespan;
            if (lifespan == null) {lifespan = 0;}
            if (lifespan > 0) {
                contexts.push(new ContextStruct(context.name, lifespan, context.parameters));
            }
            i++;
        }
        return ContextArrayToMap(contexts);
    }

    public static function ContextArrayToMap(array:Array<ContextStruct>):Map<ContextName, ContextStruct> {
        var contexts:Map<ContextName, ContextStruct> = new Map();
        for (context in array) {
            var lifespan:Null<Int> = context.lifespan;
            if (lifespan == null) {lifespan = 0;}
            contexts.set(context.name, new ContextStruct(context.name, lifespan, context.parameters));
        }
        return contexts;
    }

    //called only in backend
    public function updateServerTime(?time:Float) {
        world.storageGet().timers.serverLastTime = time != null ? time : TimeUtils.getCurrentTime();
    }

    public function getAutolistening() {
        return world.storageGet().utils.auto_listening;
    }

    //update every frame on client. Update on process intent.
    public function updateClientTime() {
        world.storageGet().timers.time = TimeUtils.getCurrentTime() + world.storageGet().timers.clientDeltaTime;
        var client = world.storageGet().clientStruct;
        if (client != null) {
            client.time = TimeUtils.getCurrentTime();
        }
    }

    //Count every time client received responce.
    public function updateClientDeltaTime() {
        world.storageGet().timers.clientDeltaTime = world.storageGet().timers.serverLastTime - TimeUtils.getCurrentTime();
        updateClientTime();
    }

    public function update() {
        var prevTime = world.storageGet().timers.time;
        var prevTimeClient:Float = 0;
        var client = world.storageGet().clientStruct;
        if (client != null) {
            prevTimeClient = client.time;
        }
        updateClientTime();
        world.timers.update(true);
        world.storageGet().timers.timerDelta = world.storageGet().timers.time - prevTime;
        var client = world.storageGet().clientStruct;
        if (client != null) {
            client.timerDeltaClient = client.time - prevTimeClient;
        }

    }

    public function postProcessIntent(response:OutputResponce) {
        var clientStruct = world.storageGet().clientStruct;
    }

    public function processPurchase(?data:Dynamic) {
        intentProcessor.processIntent(IAP_BUY, data);
    }

    //TODO сейчас не приходит если произошла ошибка
    public function sendInputRawRequest(data:String) {
        AnalyticsHelper.sendInputRequestRawEvent(world, data);
    }

    public function processIntent(intentStart:Intent, ?data:Dynamic) {
        world.storageGet().utils.auto_listening = false;
        world.intent = intentStart;
        if (world.intent == Intent.MAIN_WELCOME) {
            var ds = world.storageGet();
            world.tutorialsModel.updateStorageOnGameRestart();
        } else {

        }

        updateClientDeltaTime();
        update();

        if (world.intent != Intent.MAIN_KEEP_WORKING) {
            world.storageGet().stat.intentIdx++;
        }
        try {
            if (world.intent == Intent.TUTORIAL_YES) {
                var tmp = world.tutorialsModel.findIntentReplacement(world.intent, data);
                world.intent = tmp.intent;
                data = tmp.data;
            }
            if (world.intent == Intent.TUTORIAL_YES) {
                world.intent = Intent.MAIN_FALLBACK;
            }

            world.canProcessIntent(world.intent, data, true);

            var haveActiveTutorial = world.tutorialsModel.tutorialsAnyActive();

            var response:OutputResponce = intentProcessor.processIntent(world.intent, data);
            postProcessIntent(response);


            world.tutorialsModel.postProcessIntent(world.intent, response.modelResult.code);

            if (AnalyticsHelper.intentExclusions.indexOf(world.intent) == -1) {
                AnalyticsHelper.sendOutputResponseEvent(world, haxe.Json.stringify(response.modelResult));
            }

            if (world.intent != Intent.MAIN_WELCOME && !world.tutorialsModel.tutorialsAnyActive()) {
                world.storageGet().utils.auto_listening = true;
            }

            response.events = world.eventGetAll();
            response.analyticEvents = world.dtdAnalytics.getEvents();

            var speechBuilder:SpeechBuilder = GameUtils.getSpeechBuilder(world);
            if (!world.speechBuilder.isEmpty()) {
                speechBuilder.text(world.speechBuilder.buildText());
                world.speechBuilder = GameUtils.getSpeechBuilder(world);
            }

            if (!intentProcessor.speechBuilder.isEmpty()) {
                speechBuilder.text(intentProcessor.speechBuilder.buildText());
                intentProcessor.speechBuilder = GameUtils.getSpeechBuilder(world);
            }

            if (!world.speechBuilderTutorial.isEmpty()) {
                if (!speechBuilder.isEmpty()) {
                    speechBuilder.breakTime(0.5);
                }
                speechBuilder.text(world.speechBuilderTutorial.buildText());
                world.speechBuilderTutorial = GameUtils.getSpeechBuilder(world);
            }

            if (continuosMatchIsEnabled()) {
               // speechBuilder.sound(SpeechWithDelaysPreductions.getSound(world, SpeechWithDelaysPreductions.getSounds(world).mic_on.name));
            }

            if (!speechBuilder.isEmpty()) {
                var text = speechBuilder.build();
                this.getNativeApi().convAsk(text);
                if (AnalyticsHelper.intentExclusions.indexOf(world.intent) == -1) {
                    AnalyticsHelper.sendOutputSpeechEvent(world, text);
                }
            }


            if (response.modelResult.code == ModelOutputResultCode.EXIT) {
                getNativeApi().convExit();
                return;
            }
            if (response.modelResult.code == ModelOutputResultCode.EXIT_AND_SAVE) {
                flush();
                getNativeApi().convExit();
                return;
            }

            world.timers.update();


            //do not save match to storage. Keep it in model
            var continuousMatchConfig = world.storageGet().continuousMatchConfig;
            world.storageGet().continuousMatchConfig = null;

            flush();

            world.storageGet().continuousMatchConfig = continuousMatchConfig;

            world.eventClear();
            var out = outputGet();
            out.intent = world.intent;
            out.response = response;
            out.continuousMatchConfig = continuousMatchConfig;
            nativeApi.convAskHtmlResponse(haxe.Json.stringify(out));
        } catch (error:String) {
            var stack = haxe.CallStack.exceptionStack();
            trace(haxe.CallStack.toString(stack));
            world.timers.update();
            processError(error);
        }
    }

    public function saveOut() {

    }

    public function setIaps(json:String) {
        world.storageGet().iap.skuGoogle = haxe.Json.parse(json);
    }


    //server use it when not have handler for intent_name
    public function processUnknownIntent(intent_name:String) {
        processError("processUnknownIntent:" + intent_name);
    }

    private function processError(error:String) {
        nativeApi.convAsk(i18n.tr("conv/error"));
        //reset states
        storageInit(dsBackupJson);
        var out = outputGet(); storageInit(dsBackupJson);
        var intent:Intent = Intent.MAIN_ERROR;
        out.intent = intent;

        var code:ModelOutputResultCode = ModelOutputResultCode.ERROR;
        var stack = haxe.CallStack.exceptionStack();
        var modelResult:ModelOutputResponse = {code : ModelOutputResultCode.ERROR, data:{error:error, stack:stack }};
        world.dtdAnalytics = new DtdAnalytics();
        out.response = {
            modelResult : modelResult,
            events : new Array(),
            analyticEvents : new Array()
        };
        AnalyticsHelper.sendProcessErrorEvent(world, error, Std.string(stack));
        nativeApi.convAskHtmlResponse(haxe.Json.stringify(out));
    }

    //save current struct to native
    public function flush() {
        nativeApi.saveStorage(haxe.Json.stringify(world.storageOutputGet()));
        for (context in world.contextGetAll()) {
            nativeApi.contextSet(context.name, context.lifespan, context.parameters);
        }
        nativeApi.flushDone();
    }

    public function outputGet():OutputStruct {
        var contexts:Map<ContextName, ContextStruct> = new Map();
        var contextsArray:Array<ContextStruct> = new Array();

        var worldContexts:Array<ContextStruct> = world.contextGetAll();

        for (context in worldContexts) {contexts.set(context.name, context);}

        for (context in contexts) {
            if (context.lifespan > 0) {
                contextsArray.push(context);
            }
        }
        var storage = world.storageOutputGet();
        var out:OutputStruct = {
            storage : storage,
            contexts : contextsArray,
            continuousMatchConfig : null
        };

        return out;
    }


    public function getNativeApi():NativeApi {
        return this.nativeApi;
    }

    public function continuosMatchIsEnabled() {
        return world.storageGet().continuousMatchConfig != null;
    }

    public function continuosMatchGetJson() {
        var config = world.storageGet().continuousMatchConfig;
        if (config == null) {return "";}
        return Json.stringify(config);
    }

    public function continuosMatchSetWords() {
        trace("continuosMatchSetWords");
        var match = world.storageGet().continuousMatchConfig;
        if (match != null) {
            if (world.storageGet().serverStruct != null) {
                var addedWords:Map<String, Bool> = new Map();
                for (word in MatchWords.getForWorld(world)) {
                    addedWords.set(word, true);
                    match.expected_phrases.push({phrase:word});
                }
            }
        } else {
            trace("no match");
        }
    }


    //Load all heavy dependencies. Localizations,configs and etc.
    public static function load() {
        Intents.init();
        var time = TimeUtils.getCurrentTime();
        Configs.getConfigByLocale("en");
        trace("load configs" + (TimeUtils.getCurrentTime() - time));
        time = TimeUtils.getCurrentTime();
        Localization.getI18n("en");
        trace("load locale" + (TimeUtils.getCurrentTime() - time));
        SpeechCommands.load();
        MatchWords.load();
    }

    public static function jsonToDynamic(json:String) {
        return haxe.Json.parse(json);
    }

    public static function prepareStorage(storage:String, user:String, version:String) {
        var storage = haxe.Json.parse(storage);
        storage.user = haxe.Json.parse(user);
        storage.version = haxe.Json.parse(version);
        return haxe.Json.stringify(storage);
    }
}


typedef OutputResponce = {
var modelResult:ModelOutputResponse;
var events:Array<ModelEvent>;
var analyticEvents:Array<DtdAnalyticsBaseEvent>;
}

typedef OutputStruct = {
var storage:Dynamic;
var contexts:Array<ContextStruct>;
    @:optional var intent:Intent;
    @:optional var response:OutputResponce;
    @:optional var continuousMatchConfig:ContinuousMatchConfigStruct;
}


