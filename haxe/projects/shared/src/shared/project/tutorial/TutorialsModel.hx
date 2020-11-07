package shared.project.tutorial;
import shared.base.output.ModelOutputResultCode;
import shared.project.configs.GameConfig;
import shared.project.enums.Intent;
import shared.project.model.World;
import shared.project.tutorial.tutorials.TutorialBase.IntentDataPair;
import shared.project.tutorial.tutorials.TutorialBase;
@:expose @:keep
class TutorialsModel {

    private var tutorialsOrder:Array<TutorialBase> = new Array();
    private var world:World;

    public function new(world:World) {
        this.world = world;
        storageChanged();
    }

    public function storageChanged() {
        initTutorials();
        initTutorialsOrder();
    }

    private function initTutorials() {

    }

    private function initTutorialsOrder() {
        tutorialsOrder = [

        ];
    }

    public function postProcessIntent(name:Intent, code:ModelOutputResultCode) {
        checkAndStart(name, code);
        for (tutorial in tutorialsOrder) {
            if (tutorial.canProcess()) {
                tutorial.postProcessIntent(name, code);
            }
        }
    }

    public function canProcessIntent(name:Intent, ?data:Dynamic) {
        for (tutorial in tutorialsOrder) {
            if (tutorial.canProcess()) {
                if (name == Intent.TUTORIAL_NO) {
                    //если какой-то тутор умеет обработать no. То он его заберет,а остальные проигнорируют.
                    if (tutorial.canProcessNo()) {return true;}
                } else {
                    if (!tutorial.canProcessIntent(name, data)) {return false;}
                }
            }
        }
//по умолчанию no нельзя обработать. TUTORIAL_NO
        return name != Intent.TUTORIAL_NO;
    }

    public function checkAndStart(name:Intent, ?data:Dynamic) {
        if (!tutorialsAnyActive() && name != Intent.MAIN_WELCOME) {
            for (tutorial in tutorialsOrder) {
                if (tutorial.canStart()) {
                    tutorial.checkAndStart(name, data);
                    if (tutorial.isStarted()) {
                        break;
                    }
                }
            }
        }
    }


    public function tutorialsDebugGetActive():Array<TutorialTypedef> {
        var result:Array<TutorialTypedef> = new Array();
        for (tutorial in tutorialsOrder) {
            if (tutorial.isStarted()) {
                result.push(tutorial.def);
            }
        }
        return result;
    }

    public function tutorialsAnyActive():Bool {
        return tutorialsDebugGetActive().length > 0;
    }



    public function skip() {
        for (tutorial in tutorialsOrder) {
            tutorial.complete(true);
        }

    }


    //reset user tutorials or storage when he restart game
    public function updateStorageOnGameRestart() {
        for (tutorial in tutorialsOrder) {
            if (tutorial.isStarted()) {
                tutorial.checkOnGameRestart();
            }
        }

    }


    //start tutorials that should be started on game end loading
    public function startTutorialWhenLoadGameDone() {

    }

    public function findIntentReplacement(intent:Intent, ?data:Dynamic):IntentDataPair {
        if (GameConfig.PLATFORM == Platform.GOOGLE) {
            for (tutor in tutorialsOrder) {
                if (tutor.isStarted()) {
                    var tmp:IntentDataPair;
                    tmp = tutor.replaceIntent(intent, data);
                    if (tmp.intent != intent) return tmp;
                }
            }
        }
        return {intent: intent, data:data};
    }

    public function replaceCurrentIntent(intent:Intent, ?data:Dynamic) {
        world.intent = intent;
        return world.intentProcessor.processIntent(intent);
    }

}
