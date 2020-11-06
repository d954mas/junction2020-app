package shared.base.event;

import shared.project.model.World;
enum abstract ModelEventName(String) {
    var TUTORIAL_STARTED;
    var TUTORIAL_COMPLETED;
    var TUTORIAL_PART_CHANGED;
    var LEVEL_NEW;
}

class EventHelper {

    public static function levelNew(world:World):Void {
        world.eventEmit(LEVEL_NEW);
    }
}
