package shared.project.storage;

import shared.project.enums.UnitType;
import shared.project.model.units.BasicUnitModel;
import shared.project.enums.GameEnums.RoadType;
import shared.project.storage.Storage.LevelEnemyStruct;
import haxe.DynamicAccess;
import shared.project.timers.BaseTimer.TimerStatus;
import shared.project.tutorial.tutorials.TutorialBase;

typedef VersionStorageStruct = {
    var version:String;
    var time:Int;
    var server:String;
}

typedef StatStorageStruct = {
    var startGameCounter:Int;
    var version:Int;
    var intentIdx:Int;
    var platform:String;
    var device:String;
    var dayAfterInstall:Int;
    var gameConfigVersion:String;
    var gameLocaleVersion:String;
    var gameSharedVersion:String;
    var gameBackendVersion:String;
    var userLevel:Int;
}

typedef UserStorageStruct = {
    var name:String;
    var locale:String;
    var permissions:Array<String>;
    var verification:String;
    @:optional var lastSeen:String;
}


typedef IapStorageStruct = {
    var current_iap:String;
    var skuGoogle:Null<Dynamic>;
}


typedef TimerStorageStruct = {
    var startTime:Float; //-1 if disabled
    var endTime:Float; //-1 if disabled
    var timeLeft:Float; //-1 if disabled
    var status:TimerStatus; //-1 if disabled
}

typedef TimersStorageStruct = {
    var serverLastTime:Float; //time of last responce in server.Set when restore storage.Also set when intent processing done
    var clientDeltaTime:Float; //0 in server. In client it calc like, serverTime - clientTime
    var time:Float; //client system time + clientDeltaTime. Update when process intent in server. Or every frame in client
    var timerDelta:Float; //delta from prev update timer
}

typedef ProfileStorageStruct = {
    var cheatsEnabled:Bool;
    var uuid:String;
    var tag:String;//Чтобы различать наши стейты=)
    var isDev:Bool;
    var dtdId:String;
    //нужно чтобы запретить одновременную игру с нескольких аккаунтов.
    var conversationIdAtStart:String;
    var conversationIdCurrent:String;
    var currentVersion:String;
    var firstLaunchTimestamp:Null<Int>;
}

typedef ContinuousMatchConfigExpectedPhraseStruct = {
    var phrase:String;
}
typedef ContinuousMatchConfigStruct = {
    var expected_phrases:Array<ContinuousMatchConfigExpectedPhraseStruct>;
    var duration_seconds:Int;
}

typedef UtilsStruct = {
    var auto_listening:Bool;
}

typedef CastleStruct = {
    var idx:Int;
}

typedef LevelPlayerOrAiStruct = {
    var id:Int;
}

typedef LevelPlayerStruct = {
    > LevelPlayerOrAiStruct,
    var money:Int;
    var mana:Int;
}

typedef LevelEnemyStruct = {
    > LevelPlayerOrAiStruct,
}

typedef LevelRoadPart = {
    var idx:Int;//idx of road.Increased fir every new road
    var x:Int;
    var y:Int;
    var type:RoadType;
}

typedef LevelStruct = {
    turn:Int,
    player:LevelPlayerStruct,
    enemy:LevelEnemyStruct,
    castles:Array<CastleStruct>,
    roads:Array<Array<LevelRoadPart>>,
    units:Array<BattleUnitStruct>,
    unitIdx:Int,
}

typedef StorageStruct = {
    var user:UserStorageStruct;
    var version:VersionStorageStruct;
    var stat:StatStorageStruct;
    var profile:ProfileStorageStruct;
    var iap:IapStorageStruct ;
    var serverStruct:ServerStruct;
    @:optional var continuousMatchConfig:ContinuousMatchConfigStruct;
    @:optional var clientStruct:ClientStruct;
    var timers:TimersStorageStruct;
    var tutorials:DynamicAccess<TutorialTypedef>;
    var utils:UtilsStruct;
    @:optional var level:LevelStruct;
}

typedef ClientStruct = {
    var timerDeltaClient:Float;
    var time:Float;
}

typedef BasicUnitStruct = {
    var roadPartIdx:Int;
    var id:Int;
}

typedef BattleUnitStruct = {
    >BasicUnitStruct,
    var hpLvl:Int;
    var hp:Int;
    var ownerId:Int;
    var type:UnitType;
    var attackLvl:Int;
    var attackRange:Int;
    var reward:Int;
}

//region server struct
//Доступна только на сервере.Клиенту не отсылается. например тут лежит список доступных слов для врага
typedef ServerStruct = {

}


//endregion
class Storage {
    private static inline var VERSION:Int = 2;

    public static function initNewStorage(data:StorageStruct, force = true) {
        if (data.stat == null || force) {
            data.stat = {
                version : VERSION,
                startGameCounter:0,
                intentIdx:0,
                platform:"sber",
                device:"sberbox",
                dayAfterInstall:0,
                gameConfigVersion:"",
                gameLocaleVersion:"",
                gameSharedVersion:"",
                gameBackendVersion:"",
                userLevel:1,
            }
            data.iap = {
                current_iap : "",
                skuGoogle : null,
            }
            var uuid = Uuid.v4();
            if (data.profile != null && data.profile.uuid != null) {
                uuid = data.profile.uuid;
            }
            var tag = "";
            if (data.profile != null && data.profile.tag != null) {
                tag = data.profile.tag;
            }
            var idAtStart = "";
            var idCurrent = "";
            if (data.profile != null && data.profile.conversationIdAtStart != null) {
                idAtStart = data.profile.conversationIdAtStart;
            }
            if (data.profile != null && data.profile.conversationIdCurrent != null) {
                idCurrent = data.profile.conversationIdCurrent;
            }
            var isDev = false;
            if (data.profile != null && (data.profile.isDev == false || data.profile.isDev == true)) {
                isDev = data.profile.isDev;
            }
            var firstLaunchTimestamp = Math.round(Date.now().getTime() / 1000);
            if (data.profile != null && data.profile.firstLaunchTimestamp != null) {
                firstLaunchTimestamp = data.profile.firstLaunchTimestamp;
            }
            var dtdId = Uuid.v4();
            //перегенерация id считаем что это новый аользователь.
            // if (data.profile != null && data.profile.dtdId != null) {
            // dtdId = data.profile.dtdId;
            // }

            data.profile = {
                cheatsEnabled:false,
                uuid:uuid,
                tag:tag,
                isDev: isDev,
                conversationIdAtStart:idAtStart,
                conversationIdCurrent:idCurrent,
                currentVersion:"",
                dtdId:dtdId,
                firstLaunchTimestamp:firstLaunchTimestamp,
            }
            data.timers = {
                clientDeltaTime:0,
                serverLastTime:0,
                time:0,
                timerDelta:0,
            }
            data.level = null;
            data.serverStruct = {};
            data.utils = {auto_listening:false};
            data.tutorials = {
            }
        };
    }

    private static function migrations(data:StorageStruct) {
        if (data.stat == null) {
            initNewStorage(data);
            return;
        }
        //reset all data
        if (data.stat.version < 2) {
            initNewStorage(data, true);
        }

        data.stat.version = VERSION;
    }

    public static function restore(data:String):StorageStruct {
        var result:StorageStruct = haxe.Json.parse(data);
        if (result.serverStruct == null) {result.serverStruct = {}}
        migrations(result);
        return result;
    }

    public static function initClientStruct(storage:StorageStruct) {
        if (storage.clientStruct == null) {
            storage.clientStruct = {
                timerDeltaClient:0,
                time : 0
            }
        }

    }
}
