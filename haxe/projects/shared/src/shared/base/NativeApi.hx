package shared.base;
import shared.base.enums.ContextName;
@:expose
interface NativeApi {
    public function saveStorage(storageJson:String):Void;

    public function contextSet(name:ContextName, lifespan:Int, parameters:Null<Dynamic>):Void;

    public function convAsk(text:String):Void;

    public function convAskHtmlResponse(dataJson:String):Void;

    public function flushDone():Void;

    public function convExit():Void;
}
