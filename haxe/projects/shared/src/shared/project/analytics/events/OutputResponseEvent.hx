package shared.project.analytics.events;
import shared.project.storage.Storage.StatStorageStruct;
import shared.project.analytics.events.common.DtdAnalyticsEvent;

class OutputResponseEvent extends DtdAnalyticsEvent {
    var data:String;

    public function new(struct:StatStorageStruct, data:String) {
        super(struct);
        this.data = data;
        this.eventName = "outputResponse";
    }


}
