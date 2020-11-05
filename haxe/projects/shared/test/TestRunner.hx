import shared.Shared;
import utest.Runner;
import utest.ui.Report;

class TestRunner {
    public static function main() {
        //the long way
        Shared.load();
        var runner = new Runner();
        runner.addCase(new ServerTest());
        runner.addCase(new IntentTest());
        runner.addCase(new SpeechBuilderTest());
        runner.addCase(new TimeTest());
        runner.addCase(new TutorialTest());
        Report.create(runner);
        runner.run();

    }
}
