package shared.project.analytics.events.predefined;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
class NewLevelEvent implements DtdAnalyticsBaseEvent{
    var level:Int;
    var timestamp:Int;
    var eventName:String;

    public function new(level:Int, timestamp:Int) {
        this.level = level;
        this.timestamp = timestamp;
        this.eventName = "lu";
    }

}
