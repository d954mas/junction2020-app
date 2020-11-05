package ;
import utest.Assert;
import shared.project.enums.Intent;
import shared.Shared;
class ServerTest extends BaseTest {

    function testReloadWhenServerUpdated() {
         var shared:Shared = Utils.prepare(conv);

        shared.world.storageGet().version.version = "new";

        shared.processIntent(Intent.MAIN_FALLBACK);
        Assert.isTrue(conv.exit);
        Assert.isNull(conv.resultStruct);
    }


}
