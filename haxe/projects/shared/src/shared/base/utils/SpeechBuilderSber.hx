package shared.base.utils;

class SpeechBuilderSber extends SpeechBuilder {

    public function new() {
        super();
        str = "";
        builed = false;
    }

    public override function build():String {
        Assert.assert(!builed, "already build");
        builed = true;
        str = str + "";
        return str;
    }

    public override function breakTime(time:Float):SpeechBuilder {
        Assert.assert(!builed, "already build");
        var timeInt = Math.ceil(time * 1000);
        if (timeInt > 0) {
            str = str + '<break time="' + timeInt + 'ms"/>';
        }
        return this;
    }

    override public function mark(name:String):SpeechBuilder {
        return this;
    }


    public override function buildText():String {
        Assert.assert(!builed, "already build");
        builed = true;
        return str;
    }

    override public function sound(url:String):SpeechBuilder {
        Assert.assert(!builed, "already build");
        @:nullSafety(Off)
        url = url.substr(0, url.length - 4);
        str = str + '<audio text="game_wordkeeper_' + url + '"/>';
        return this;
    }


}
