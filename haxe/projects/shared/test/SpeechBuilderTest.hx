package ;
import shared.base.utils.SpeechBuilder;
import utest.Assert;
class SpeechBuilderTest extends utest.Test {


    function testBuild() {
        Assert.equals("<speak></speak>", new SpeechBuilder().build());
    }

    function testBreak() {
        Assert.equals('<speak><break time="5"/></speak>', new SpeechBuilder().breakTime(5).build());
        Assert.equals('<speak><break time="1"/></speak>', new SpeechBuilder().breakTime(1).build());
        Assert.equals('<speak><break time="1.5"/></speak>', new SpeechBuilder().breakTime(1.5).build());
        Assert.equals('<speak><break time="10"/></speak>', new SpeechBuilder().breakTime(10).build());
    }

    function testText() {
        Assert.equals('<speak> hello</speak>', new SpeechBuilder().text("hello").build());
        Assert.equals('<speak> hello<break time="5"/></speak>', new SpeechBuilder().text("hello").breakTime(5).build());
        Assert.equals('<speak> hello<break time="5"/> bye</speak>', new SpeechBuilder().text("hello").breakTime(5).text("bye").build());
    }
}
