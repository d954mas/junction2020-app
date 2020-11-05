package shared.project.analytics.events;
import shared.project.storage.Storage.StatStorageStruct;
import shared.project.analytics.events.common.TutorialCommon;
class TutorialStartEvent extends TutorialCommon {

    public function new(struct:StatStorageStruct, name:String) {
        super(struct, name);
        this.eventName = "tutorialStart";
    }
}
