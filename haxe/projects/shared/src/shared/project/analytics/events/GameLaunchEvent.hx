package shared.project.analytics.events;
import shared.project.analytics.events.common.DtdAnalyticsEvent;
import shared.project.storage.Storage.StatStorageStruct;
class GameLaunchEvent extends DtdAnalyticsEvent {
    var platform:String;
    var device:String;
    var dayAfterInstall:Int;
    var gameConfigVersion:String;
    var gameLocaleVersion:String;
    var gameSharedVersion:String;
    var gameBackendVersion:String;
    var source:String;
    var userCountry:String;

    public function new(struct:StatStorageStruct, source:String,
                        userCountry:String) {
        super(struct);
        this.platform = struct.platform;
        this.device = struct.device;
        this.dayAfterInstall = struct.dayAfterInstall;
        this.gameConfigVersion = struct.gameConfigVersion;
        this.gameLocaleVersion = struct.gameLocaleVersion;
        this.gameSharedVersion = struct.gameSharedVersion;
        this.gameBackendVersion = struct.gameBackendVersion;
        this.source = source;
        this.userCountry = userCountry;
        this.eventName = "gameLaunch";
    }

}
