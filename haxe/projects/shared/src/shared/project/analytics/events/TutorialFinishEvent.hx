package shared.project.analytics.events;
import shared.project.analytics.events.common.TutorialCommon;
import shared.project.storage.Storage.StatStorageStruct;
class TutorialFinishEvent extends TutorialCommon {

    public function new(struct:StatStorageStruct, name:String) {
        super(struct, name);
        this.eventName = "tutorialFinish";
    }
}
