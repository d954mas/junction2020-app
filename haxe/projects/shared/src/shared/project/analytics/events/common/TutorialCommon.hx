package shared.project.analytics.events.common;

import shared.project.storage.Storage.StatStorageStruct;
class TutorialCommon extends DtdAnalyticsEvent {
    var name:String;

    public function new(struct:StatStorageStruct, name:String) {
        super(struct);
        this.name = name;
    }
}
