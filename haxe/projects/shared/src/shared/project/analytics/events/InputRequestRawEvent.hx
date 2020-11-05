package shared.project.analytics.events;
import shared.project.analytics.events.common.DtdAnalyticsEvent;
import shared.project.storage.Storage.StatStorageStruct;

class InputRequestRawEvent extends DtdAnalyticsEvent {
    var data:String;

    public function new(struct:StatStorageStruct, data:String) {
        super(struct);
        this.data = data;
        this.eventName = "inputRequestRawEvent";
    }


}
