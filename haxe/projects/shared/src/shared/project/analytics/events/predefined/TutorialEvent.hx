package shared.project.analytics.events.predefined;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
class TutorialEvent implements DtdAnalyticsBaseEvent {
    var step:Int;
    var timestamp:Int;
    var level:Int;
    var eventName:String;
    public function new(step:Int, timestamp:Int, level:Int) {
        this.step = step;
        this.timestamp = timestamp;
        this.level = level;
        this.eventName = "tr";
    }
}
