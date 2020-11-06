package shared.project.model;
import haxe.Json;
import jsoni18n.I18n;
import shared.base.enums.ContextName;
import shared.base.model.WorldBaseModel;
import shared.base.output.ModelOutputResponse;
import shared.base.output.ModelOutputResultCode;
import shared.base.utils.GameUtils;
import shared.base.utils.SpeechBuilder;
import shared.project.analytics.DtdAnalytics;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
import shared.project.configs.GameConfig;
import shared.project.enums.Intent;
import shared.project.intent_processors.IntentProcessor;
import shared.project.storage.Storage.StorageStruct;
import shared.project.timers.Timers;
import shared.project.tutorial.TutorialsModel;

@:expose @:keep
class World extends WorldBaseModel<StorageStruct> {
    @:nullSafety(Off) public var tutorialsModel(default, null):TutorialsModel;
    public var dtdAnalytics:DtdAnalytics;
    public var timers:Timers;
    @:nullSafety(Off) public var speechBuilder:SpeechBuilder;
    @:nullSafety(Off) public var speechBuilderTutorial:SpeechBuilder;
    @:nullSafety(Off) public var i18n:I18n;
    public var isDevServer:Bool;
    public var clientIntentIdx:Int = -1;
    @:nullSafety(Off) public var levelModel:LevelModel;
    @:nullSafety(Off) public var intentProcessor:IntentProcessor;

    public function new(storage:StorageStruct) {
        super(storage);
        dtdAnalytics = new DtdAnalytics();
        timers = new Timers();
        isDevServer = false;
        tutorialsModel = new TutorialsModel(this);
        levelModel = new LevelModel(this);
        restore();
        timers.init(this);
        speechBuilder = GameUtils.getSpeechBuilder(this);
        speechBuilderTutorial = GameUtils.getSpeechBuilder(this);
    }

    public function setIntentProcessor(intentProcessor:IntentProcessor) {
        this.intentProcessor = intentProcessor;
    }

    public function setI18n(i18n:I18n) {
        this.i18n = i18n;
    }

    public override function restore():Void {
        super.restore();
    }

    public function onGameLoaded() {
        //todo add save load data when reopen game
        storage.level = null;
        if (storage.level == null) {
            levelModel.createLevel();
        }
    }

    //clear old data.That was saved in storage(for example battle)
    public function outputConversationStart():ModelOutputResponse {
        //delete all context from prev state.
        for (context in contextGetAll()) {
            contextDelete(context.name);
        }
        //Перед релизом выключить читы.
        if (isDevUser()) {contextChange(ContextName.DEV);}
        if ((isDevUser()) && storage.profile.cheatsEnabled) {outputCheatsEnable();}
        storage.profile.conversationIdAtStart = storage.profile.conversationIdCurrent;
        storage.profile.currentVersion = storage.version.version;

        return {code : ModelOutputResultCode.SUCCESS};
    }

    public function isDevUser() {
        return (isDevServer || storage.profile.isDev);
    }

    //region CHEATS
    public function outputCheatsEnable():ModelOutputResponse {
        Assert.assert(contextExist(ContextName.DEV), "cheats only worked in dev mode");
        contextChange(ContextName.CHEATS);
        storage.profile.cheatsEnabled = true;
        return {code : ModelOutputResultCode.SUCCESS};
    }

    public function outputCheatsDisable():ModelOutputResponse {
        Assert.assert(contextExist(ContextName.DEV), "cheats only worked in dev mode");
        contextDelete(ContextName.CHEATS);
        storage.profile.cheatsEnabled = false;
        return {code : ModelOutputResultCode.SUCCESS};
    }
    //endregion


    override public function storageOutputGet():StorageStruct {
        var storage = storageGet();
        var serverStruct = storage.serverStruct;
        @:nullSafety(Off) storage.serverStruct = null;
        var outStorage = haxe.Json.parse(haxe.Json.stringify(storage));
        return outStorage;
    }


    public function isDev():Bool {
        return contextExist(ContextName.DEV);
    }

    public function isCheatsEnabled():Bool {
        return isDev() && contextExist(ContextName.CHEATS);
    }

    public function canProcessIntent(name:Intent, ?data:Dynamic, throwExeption:Bool = false) {
        var list:Null<Array<ContextName>> = Intents.intentContexts.get(name);
        if (list == null) {
            trace("unknown intent " + name);
            if (throwExeption) {
                throw "unknown intent " + name;
            };
            return false;
        }
        for (ctx in list) {
            if (!contexts.exists(ctx)) {
                if (throwExeption) {
                    throw "can't process intent:" + name + " no context:" + ctx;
                }
                return false;
            }
        }
        if (Intents.ignoreTutorialCheck[name] == null) {
            var result:Bool = tutorialsModel.canProcessIntent(name, data);
            if (throwExeption && !result) {
                throw "can't process intent:" + name + " blocked by tutorial";
            }
            return result;
        } else {
            return true;
        }

    }

    public function getLocalizationSafeLua(key:String, paramsJson:Null<String>) {
        if (paramsJson == null) {
            return getLocalizationSafe(key, null);
        } else {
            var map:Map<String, Dynamic> = new Map();
            var data = Json.parse(paramsJson);
            for (k in Reflect.fields(data)) {
                map.set(k, Reflect.field(data, k));
            }
            return getLocalizationSafe(key, map);
        }
    }

    public function getLocalizationLua(key:String, paramsJson:Null<String>) {
        if (paramsJson == null) {
            return getLocalization(key, null);
        } else {
            var map:Map<String, Dynamic> = new Map();
            var data = Json.parse(paramsJson);
            for (k in Reflect.fields(data)) {
                map.set(k, Reflect.field(data, k));
            }
            return getLocalization(key, map);
        }
    }

    public function getLocalizationLuaTutorial(key:String, paramsJson:Null<String>) {
        if (paramsJson == null) {
            return getLocalizationTutorialText(key, null);
        } else {
            var map:Map<String, Dynamic> = new Map();
            var data = Json.parse(paramsJson);
            for (k in Reflect.fields(data)) {
                map.set(k, Reflect.field(data, k));
            }
            return getLocalizationTutorialText(key, map);
        }
    }

    public function trackAnalyticEvent(event:DtdAnalyticsBaseEvent) {dtdAnalytics.trackEvent(event);}


    override public function contextDeleteAll() {
        for (ctx in contextGetAll()) {
            if (ctx.name != ContextName.DEV && ctx.name != ContextName.CHEATS) {
                contextDelete(ctx.name);
            }
        }
    }

    public function getLocalization(key:String, ?params:Map<String, Dynamic>) {
        return i18n.tr(key, params);
    }

    public function getLocalizationSafe(key:String, ?params:Map<String, Dynamic>) {
        var str = i18n.tr(key, params);
        if (str == key) {
            return "";
        }
        return str;
    }

    public function getLocalizationTutorialText(key:String, ?params:Map<String, Dynamic>) {
        if (GameConfig.PLATFORM == Platform.SBER) {
            return getLocalization(key, params);
        } else {
            var tutorial_key = key + "_text";
            var text = getLocalization(tutorial_key, params);
            if (text == "" || text == tutorial_key) {
                return getLocalization(key, params);
            }
            return text;
        }

    }

    public function getUserLevel():Int {
        return storage.stat.userLevel;
    }

    public function getSessionNumber():Int {
        return storage.stat.startGameCounter;
    }

    public function getIntentIdx():Int {
        return storage.stat.intentIdx;
    }
}
