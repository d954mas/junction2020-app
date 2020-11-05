package shared.project.analytics.events;
import shared.project.storage.Storage.StatStorageStruct;
import shared.project.analytics.events.common.DtdAnalyticsEvent;
class ProcessErrorEvent extends DtdAnalyticsEvent {
    var error:String;
    var stack:String;

    public function new(struct:StatStorageStruct, error:String, stack:String) {
        super(struct);
        this.error = error;
        this.stack = stack;
    }

}
