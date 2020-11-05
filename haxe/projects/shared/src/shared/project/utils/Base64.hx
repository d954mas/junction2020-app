package shared.project.utils;


import StringTools;
import haxe.io.Bytes;
import haxe.crypto.BaseCode;
@:expose @:keep
class Base64 {
    public static var CHARS(default, null) = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    public static var BYTES(default, null) = haxe.io.Bytes.ofString(CHARS);


    public static function encode(bytes:haxe.io.Bytes, complement = true):String {
        var str = new BaseCode(BYTES).encodeBytes(bytes).toString();
        if (complement)
            switch (bytes.length % 3) {
                case 1:
                    str += "==";
                case 2:
                    str += "=";
                default:
            }
        return str;
    }

    public static function decode(str:String, complement = true):haxe.io.Bytes {
        if (complement)
            while (StringTools.fastCodeAt(str,str.length - 1) == StringTools.fastCodeAt("=",0)){
                @:nullSafety(Off) str =  str.substr(0,-1);
            }

        return new BaseCode(BYTES).decodeBytes(haxe.io.Bytes.ofString(str));
    }



    public static function encodeString(data:String):String {
        var bytes = haxe.zip.Compress.run(haxe.io.Bytes.ofString(data), 9);
        return encode(bytes);
    }

    public static function decodeString(data:String):String {
        var bytes = haxe.zip.Uncompress.run(decode(data));
        return bytes.toString();
    }

}
