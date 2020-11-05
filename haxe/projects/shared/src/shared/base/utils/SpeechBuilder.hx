package shared.base.utils;

class SpeechBuilder {
    private var str:String = "";
    private var builed:Bool = false;

    public function new() {
        str = "<speak>";
        builed = false;
    }

    public function build():String {
        Assert.assert(!builed, "already build");
        builed = true;
        str = str + "</speak>";
        return str;
    }

    public function buildText():String{
        Assert.assert(!builed, "already build");
        builed = true;
        return   str.substring(7);
    }

    public function text(text:String):SpeechBuilder {
        Assert.assert(!builed, "already build");
        str = str + " " + text;
        return this;
    }

    public function breakTime(time:Float):SpeechBuilder {
        Assert.assert(!builed, "already build");
        str = str + '<break time="' + time + '"/>';
        return this;
    }

    public function sound(url:String):SpeechBuilder {
        Assert.assert(!builed, "already build");
        str = str + '<audio src="' + url + '"/>';
        return this;
    }

    public function mark(name:String):SpeechBuilder {
        Assert.assert(!builed, "already build");
        str = str + '<mark name="' + name + '"/>';
        return this;
    }

    public function textRepeat(text:String, count:Int, delay:Float) {
        Assert.assert(count >= 1, "count is too low:" + count);
        this.text(text);
        for (i in 1...count) {
            breakTime(delay);
            this.text(text);
        }
    }

    public function isEmpty() {
        return str == "<speak>" || str == "<speak></speak>" || str == "";
    }
}
