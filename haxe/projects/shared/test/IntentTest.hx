package ;
import shared.project.enums.Intent;
import shared.Shared;
import utest.Assert;
class IntentTest extends BaseTest {

    function testWelcome() {
         var shared:Shared = Utils.prepare(conv);
        Utils.assertResultCodeEquals(conv);

    }


    function testMultipleDevices() {
        var shared:Shared = Utils.prepare(conv);
        shared.setConversationID("1");
        shared.processIntent(Intent.MAIN_WELCOME);
        Utils.assertResultCodeEquals(conv);
        Assert.equals("1", conv.storage.profile.conversationIdAtStart);
        Assert.equals("1", conv.storage.profile.conversationIdCurrent);
        shared.processIntent(Intent.MAIN_FALLBACK);
        Assert.equals("1", conv.storage.profile.conversationIdAtStart);
        Assert.equals("1", conv.storage.profile.conversationIdCurrent);

        shared.setConversationID("2");
        shared.processIntent(Intent.MAIN_FALLBACK);
        Assert.isNull(conv.resultStruct);
        Assert.isTrue(conv.exit);
        //db was not updated
        Assert.equals("1", conv.storage.profile.conversationIdCurrent);
        Assert.equals("1", conv.storage.profile.conversationIdCurrent);
        conv.exit = false;

        shared.setConversationID("2");
        shared.processIntent(Intent.MAIN_WELCOME);
        Utils.assertResultCodeEquals(conv);
        Assert.equals("2", conv.storage.profile.conversationIdAtStart);
        Assert.equals("2", conv.storage.profile.conversationIdCurrent);

    }

}
