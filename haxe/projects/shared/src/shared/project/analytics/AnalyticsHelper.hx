package shared.project.analytics;
import shared.project.analytics.events.*;
import shared.project.analytics.events.OutputSpeechEvent;
import shared.project.analytics.events.predefined.GameSessionEvent;
import shared.project.analytics.events.predefined.PlayerInfoEvent;
import shared.project.analytics.events.predefined.TutorialEvent;
import shared.project.enums.Intent;
import shared.project.model.World;
class AnalyticsHelper {
    public static function sendProcessIntentEvent(world:World, intent:Intent, ?data:Dynamic) {
        var dataString:String;
        if (data != null)
            dataString = Std.string(data);
        else dataString = "";
        var event = new ProcessIntentEvent(
        world.storageGet().stat,
        Std.string(intent),
        dataString
        );
        world.trackAnalyticEvent(event);
    }


    public static function sendGameLaunchEvent(world:World) {
        var storage = world.storageGet();
        var event = new GameLaunchEvent(
        storage.stat,
            //TODO:Source and country strings
        "Not implemented.",
        "Not implemented."
        );
        world.trackAnalyticEvent(event);
    }


    public static function sendTutorialPartChangedEvent(world:World, name:String, prev:Null<String>, currentPart:Null<String>, prevPartIdx:Int) {
        var prevSafe:String;
        if (prev != null)
            prevSafe = prev;
        else prevSafe = "";
        if (currentPart != null) {
            var event = new TutorialPartChangedEvent(
            world.storageGet().stat,
            prevSafe,
            currentPart,
            name
            );
            world.trackAnalyticEvent(event);
        }
        else throw "no_current_tutorial_part_data";
        if (tutorNameToStep.exists(name)) {
            var step:Int;
            step = prevPartIdx;
            if (step != -1 || name == FIRST_TUTOR) {
                 sendTutorialEvent(world, getStep(name, step));
            }
        }
    }

    public static function sendTutorialFinishedEvent(world:World, name:String) {
        var event = new TutorialFinishEvent(
        world.storageGet().stat,
        name
        );
        world.trackAnalyticEvent(event);
        if (tutorNameToStep.exists(name)) {
            sendTutorialEvent(world, getStep(name, 99));
        }
    }

    public static function sendTutorialStartedEvent(world:World, name:String) {
        var event = new TutorialStartEvent(
        world.storageGet().stat,
        name
        );
        world.trackAnalyticEvent(event);
    }

    public static function sendGameSessionEvent(world:World) {
        var event = new GameSessionEvent(Math.round(Date.now().getTime() / 1000), 0, world.storageGet().stat.userLevel);

        world.trackAnalyticEvent(event);
    }


    public static function sendPlayerInfoEvent(world:World) {
        var storage = world.storageGet();
        var event = new PlayerInfoEvent(
        Math.round(Date.now().getTime() / 1000),
        storage.stat.userLevel
        );
        world.trackAnalyticEvent(event);
    }

    public static function sendProcessErrorEvent(world:World, error:String, stack:String) {
        var event = new ProcessErrorEvent(
        world.storageGet().stat,
        error,
        stack
        );
        world.trackAnalyticEvent(event);
    }

    public static function sendOutputResponseEvent(world:World, data:String) {
        var event = new OutputResponseEvent(
        world.storageGet().stat,
        data
        );
        world.trackAnalyticEvent(event);
    }


    public static function sendInputRequestRawEvent(world:World, data:String) {
        if (AnalyticsHelper.intentExclusions.indexOf(world.intent) == -1) {
            var event = new InputRequestRawEvent(
            world.storageGet().stat,
            data
            );
            world.trackAnalyticEvent(event);
        }
    }


    public static function sendOutputSpeechEvent(world:World, data:String) {
        var event = new OutputSpeechEvent(
        world.storageGet().stat,
        data
        );
        world.trackAnalyticEvent(event);
    }

    public static function sendTutorialEvent(world:World, step:Int) {
        var event = new TutorialEvent(
        step,
        Math.round(Date.now().getTime() / 1000),
        world.storageGet().stat.userLevel
        );
        world.trackAnalyticEvent(event);
    }

    private static function getStep(tutorName:String, stepNum:Int) {
        if (tutorName == FIRST_TUTOR && stepNum == -1) return -1;
        if (tutorName == LAST_TUTOR && stepNum == 99) return -2;
        var stepBase = tutorNameToStep[tutorName];
        if (stepBase == null) throw "no_steps_defined_for_tutor_" + tutorName;
        return stepBase + stepNum;
    }

    private static inline var FIRST_TUTOR = "Level1Battle";
    private static inline var LAST_TUTOR = "Level5Battle";
    public static var intentExclusions:Array<Intent> = [Intent.MAIN_KEEP_WORKING];
    private static var tutorNameToStep:Map<String, Int> = ["Level1Battle" => 100,
        "Level2Battle" => 200, "Level3Battle" => 300, "Help" => 400, "Level4Battle" => 500,
        "Level5Battle" => 600];
}

