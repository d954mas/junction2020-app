package shared.project.intent_processors;
import jsoni18n.I18n;
import shared.base.enums.ContextName;
import shared.project.enums.Intent;
import shared.project.model.World;
import shared.Shared.OutputResponce;

class IntentSubProcessor {
    @:nullSafety(Off) private var baseProcessor:IntentProcessor;
    private var world:World;
    private var i18n:I18n;
    private var shared:Shared;

    public function new(world, shared, i18n) {
        this.world = world;
        this.shared = shared;
        this.i18n = i18n;
    }

    public function setBaseProcessor(baseProcessor:IntentProcessor) {
        this.baseProcessor = baseProcessor;
    }

    public function ask(text) {
        this.baseProcessor.speechBuilder.text(text);
    }

    public function contextChange(name:ContextName, ?lifespan:Int, ?parameters:Dynamic) {
        this.world.contextChange(name, lifespan, parameters);
    }

    public function contextDelete(name:ContextName) {
        this.world.contextDelete(name);
    }

    public function contextExist(name:ContextName) {
        return this.world.contextExist(name);
    }

    public function processIntent(intent:Intent, ?data:Dynamic):Null<OutputResponce> {
        return null;
    }
}
