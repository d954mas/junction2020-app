package shared.base.event;

import shared.project.model.World;
enum abstract ModelEventName(String) {
    var TUTORIAL_STARTED;
    var TUTORIAL_COMPLETED;
    var TUTORIAL_PART_CHANGED;
    var LEVEL_NEW;
    var LEVEL_MOVE_TO_NEXT;
}

class EventHelper {

    public static function levelNew(world:World):Void {
        world.eventEmit(LEVEL_NEW);
    }

    public static function levelMoveToNext(world:World):Void {
        world.eventEmit(LEVEL_MOVE_TO_NEXT);
    }
}

