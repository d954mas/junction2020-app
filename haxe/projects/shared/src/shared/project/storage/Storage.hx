package shared.project.storage;

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
}

typedef ClientStruct = {
    var timerDeltaClient:Float;
    var time:Float;
}

//region server struct
//Доступна только на сервере.Клиенту не отсылается. например тут лежит список доступных слов для врага
typedef ServerStruct = {

}


//endregion
class Storage {
    private static inline var VERSION:Int = 1;

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
        if (data.stat.version < 1) {
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