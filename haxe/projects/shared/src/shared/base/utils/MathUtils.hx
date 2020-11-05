package shared.base.utils;
class MathUtils {
    public static function clamp(value:Float, min:Float, max:Float) {
        return Math.min(Math.max(min, value), max);
    }
}
