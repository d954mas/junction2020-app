package ;
import shared.Shared;
class BaseTest extends utest.Test {
    var conv:FakeConversation;
    var startTimeTest:Float;
    var startTimeAll:Float;
    var logTime:Bool = false;

    private function getTime():Float {
        #if lua
            return Sys.time();
        #end
        return Date.now().getTime();
    }


    function setupClass():Void {
        startTimeAll = getTime();
    }

    function teardownClass():Void {
        if(logTime)trace("All Test time:" + (getTime() - startTimeAll));
    }

    function teardown():Void {
        if(logTime)trace("Test time:" + (getTime() - startTimeTest));
    }


    function setup():Void {
        // Shared.load();
        conv = new FakeConversation();
        startTimeTest = getTime();
    }
}
