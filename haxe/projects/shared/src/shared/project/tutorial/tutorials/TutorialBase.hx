package shared.project.tutorial.tutorials;

import shared.project.analytics.AnalyticsHelper;
import shared.project.analytics.events.TutorialFinishEvent;
import shared.project.analytics.events.TutorialStartEvent;
import shared.project.analytics.events.TutorialPartChangedEvent;
import shared.base.event.ModelEventName;
import shared.base.output.ModelOutputResultCode;
import shared.project.enums.Intent;
import shared.project.model.World;

typedef TutorialTypedefPart = {
var id:String;
}
typedef TutorialTypedef = {
var id:String;
var needCompletedTutorials:Array<String>;
var currentPart:Null<String>;
var completed:Bool;
}
typedef IntentDataPair = {
var intent:Intent;
var ?data:Dynamic;
}

@:expose @:keep
class TutorialBase {
    @:nullSafety(Off) public var def:TutorialTypedef;
    private var world:World;
    private var parts:Array<TutorialTypedefPart>;

    public function new(world:World, id:String, parts:Array<TutorialTypedefPart>) {
        this.world = world;
        @:nullSafety(Off) def = world.storageGet().tutorials[id];
        if (def == null) { throw "no def for tutorial:" + id;}
        if (def.id != id) { throw "bad id.Excepted:" + id + " get:" + def.id;}
        this.parts = parts;
    }

    //first step of tutorial
    public function start() {
        Assert.assert(canStart(), "can't start tutotial:" + def.id);
        var part:Null<TutorialTypedefPart> = parts[0];
        if (part == null) {throw "can't start no part";}
        def.currentPart = part.id;
        world.eventEmit(ModelEventName.TUTORIAL_STARTED, {tutorial: def.id});
        world.eventEmit(ModelEventName.TUTORIAL_PART_CHANGED, {tutorial:def.id, part : def.currentPart});
        onPartChanged(null);
        onStarted();
       // world.battleModel.continuousModeStartIfCan();//for tutorials that start battle.
    }

    ///@param onlyStorage. it true only change storage for current tutorial.
    public function complete(onlyStorage:Bool = false) {
        def.currentPart = null;
        def.completed = true;
        if (!onlyStorage) {
            world.eventEmit(ModelEventName.TUTORIAL_COMPLETED, {tutorial: def.id});
            onCompleted();
        }
    }

    public function getCurrentPart():Null<String> {
        return def.currentPart;
    }

    private function findPartIdxById(id:Null<String>):Int {
        if (id == null) {return -1;}
        for (i in 0...parts.length) {
            if (parts[i].id == id) {
                return i;
            }
        }
        return -1;
    }

    public function changeToNextPart() {
        var currentIdx = findPartIdxById(def.currentPart);
        changeToPart(parts[currentIdx + 1].id);
    }

    public function canProcessNo() {
        return false;
    }

    public function changeToPart(part:String) {
        var currentIdx = findPartIdxById(def.currentPart);
        var nextIdx = findPartIdxById(part);
        var currentPart = def.currentPart;
        if (currentPart != null) {
            if (currentPart == part) {
                throw "change to current part";
            } else {
                if (currentIdx == -1) { throw "unknow part state:" + currentPart;}
                if (nextIdx == -1) { throw "unknow new part state:" + nextIdx;}
            }
        }
        if (currentIdx + 1 != nextIdx) { throw 'can change from part:${currentPart}($currentIdx}) to part:${part}($nextIdx)}';}
        def.currentPart = part;
        world.eventEmit(ModelEventName.TUTORIAL_PART_CHANGED, {tutorial:def.id, part : def.currentPart, prevPart : currentPart});
        onPartChanged(currentPart);
      //  world.battleModel.continuousModeStartIfCan();
    }

    public function onPartChanged(prev:Null<String>) {
        AnalyticsHelper.sendTutorialPartChangedEvent(world, def.id, prev, def.currentPart, findPartIdxById(prev));
    }

    public function onCompleted() {
        AnalyticsHelper.sendTutorialFinishedEvent(world, def.id);
    }

    public function onStarted() {
        AnalyticsHelper.sendTutorialStartedEvent(world, def.id);
    }

    public function canProcess() {
        return def.currentPart != null && !def.completed;
    }

    public function isStarted() {
        return def.currentPart != null;
    }

    public function isCompleted() {
        return def.completed;
    }

    public function reset() {
        def.currentPart = null;
    }

    public function resetAll() {
        def.currentPart = null;
        def.completed = false;
    }

    public function canStart() {
        return def.currentPart == null && !def.completed;
    }

    public function postProcessIntentUpdate(name:Intent, code:ModelOutputResultCode) {

    }


    public function checkAndStart(name:Intent, ?data:Dynamic) {

    }

    public function canProcessIntent(name:Intent, ?data:Dynamic):Bool {
        return true;
    }

    public function postProcessIntent(name:Intent, code:ModelOutputResultCode) {
        if (canProcess()) {
            postProcessIntentUpdate(name, code);
        }
    }

    public function checkOnGameRestart() {
        if (isStarted()) {
            reset();
        }
    }

    public function replaceIntent(intent:Intent, ?data:Dynamic):IntentDataPair {
        return {intent: intent, data: data};
    }
}