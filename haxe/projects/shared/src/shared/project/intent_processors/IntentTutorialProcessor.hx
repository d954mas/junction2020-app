package shared.project.intent_processors;
import shared.base.enums.ContextName;
import shared.base.output.ModelOutputResultCode;
import shared.project.enums.Intent;
import shared.Shared.OutputResponce;

class IntentTutorialProcessor extends IntentSubProcessor {


    public override function processIntent(intent:Intent, ?data:Dynamic):Null<OutputResponce> {
        var storage = world.storageGet();
        switch(intent){
            default:return null;
        }
    }
}
