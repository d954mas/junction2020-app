package shared.project.analytics.events.predefined;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
class PlayerInfoEvent implements DtdAnalyticsBaseEvent {
    var timestamp:Int;
    var data:Map<String, Any>;
    var eventName:String;
    public function new(timestamp:Int, userLevel:Int) {
        this.timestamp = timestamp;
        data = new Map();
        data["userLevel"] = userLevel;
        this.eventName = "pl";
    }
}
