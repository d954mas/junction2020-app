package shared.project.analytics.events;
import shared.project.analytics.events.common.DtdAnalyticsEvent;
import shared.project.storage.Storage.StatStorageStruct;
class ProcessIntentEvent extends DtdAnalyticsEvent {
    var name:String;
    var data:String;

    public function new(struct:StatStorageStruct, name:String, data:String) {
        super(struct);
        this.name = name;
        this.data = data;
        this.eventName = "processIntent";
    }


}
