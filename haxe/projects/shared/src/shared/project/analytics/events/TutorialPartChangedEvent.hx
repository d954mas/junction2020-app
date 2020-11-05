package shared.project.analytics.events;
import shared.project.storage.Storage.StatStorageStruct;
import shared.project.analytics.events.common.TutorialCommon;
class TutorialPartChangedEvent extends TutorialCommon {
    var prev:String;
    var New:String;

    public function new(struct:StatStorageStruct, prev:String, New:String, name:String) {
        super(struct, name);
        this.prev = name +"_" +  prev;
        this.New = name + "_" + New;
        this.eventName = "tutorialPartChanged";
    }
}
