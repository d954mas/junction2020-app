package shared.project.analytics.events.predefined;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
class GameSessionEvent implements DtdAnalyticsBaseEvent{
    var timestamp:Int;
    var length: Null<Int>;
    var level:Int;
    var eventName:String;

    public function new(timestamp:Int, length:Int, level:Int) {
        this.timestamp = timestamp;
        this.length = length;
        this.level = level;
        this.eventName = "gs";
    }

}
