package shared.project.utils;

@:expose @:keep
class TimeUtils {

    public static final SECOND:Int = 1000;
    public static final MINUTE:Int = SECOND*60;
    public static final HOUR:Int = MINUTE*60;
    //@return current time in ms.
    public static function getCurrentTime():Float {
        #if lua
        return cast Sys.time()*1000;
        #end
        return cast Date.now().getTime();
    }

    //@return string in format YYYY-MM-DD HH:MM:SS
    public static function timeToString(time:Int):String {
        return Date.fromTime(time).toString();
    }
    //@return string in format current Day + time
    public static function timeToStringShort(time:Int):String {
        return DateTools.format(Date.fromTime(time), "%d %H:%M:%S");
    }
}
