package shared.project.analytics.events.common;
import shared.project.storage.Storage.StatStorageStruct;
class DtdAnalyticsEvent implements DtdAnalyticsBaseEvent {
    var session:Int;
    var intentIdx:Int;

    var userLevel:Int;
    /*var levelLast:Int;
    var levelPrev:Int;*/
    var eventName:String="";

    function new(struct:StatStorageStruct) {
        session = struct.startGameCounter;
        intentIdx = struct.intentIdx;
        userLevel = struct.userLevel;
        /*levelLast = struct.levelLast;
        levelPrev = struct.levelPrev;*/
    }
}
