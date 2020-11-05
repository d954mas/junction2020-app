package ;
import shared.project.timers.BaseTimer.TimerStatus;
import shared.project.configs.GameConfig;
import utest.Assert;
import shared.base.NativeApi;
import shared.base.NativeApi;
import shared.project.enums.Intent;
import shared.project.utils.TimeUtils;
import shared.Shared;
import utest.Assert;
class TimeTest extends BaseTest {


    function testServerTimeSet() {
         var shared:Shared = Utils.prepare(conv);
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.serverLastTime));
    }

    function testClientTimeSet() {
         var shared:Shared = Utils.prepare(conv);
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.time));
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.clientDeltaTime, 0));
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.serverLastTime, conv.storage.timers.time));
    }

    function testClientTimeWithDelta() {
        var shared:Shared = conv.getShared();
        var hour:Int = 60 * 60 * 1000;
        shared.updateServerTime(TimeUtils.getCurrentTime() + hour);//add 1 hour
        shared.processIntent(Intent.MAIN_WELCOME);
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.serverLastTime, TimeUtils.getCurrentTime() + hour));
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.clientDeltaTime, hour));
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.time, conv.storage.timers.serverLastTime));

        shared.updateServerTime(TimeUtils.getCurrentTime() - hour);//remove 1 hour
        shared.processIntent(Intent.MAIN_WELCOME);
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.serverLastTime, TimeUtils.getCurrentTime() - hour));
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.clientDeltaTime, -hour));
        Assert.isTrue(Utils.timeEqual(conv.storage.timers.time, conv.storage.timers.serverLastTime));
    }



}
