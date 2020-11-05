package shared.project.timers;
import shared.project.model.World;

@:nullSafety(Off)
@:keep
class Timers {
    private var world:World;

    public function new() {}

    public function init(world:World) {
        this.world = world;
    }

    public function update(firstTime:Bool = false) {
    }
}
