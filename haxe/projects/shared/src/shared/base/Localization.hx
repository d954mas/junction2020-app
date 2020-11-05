package shared.base;
import jsoni18n.I18n;
class Localization {
    private static var eng:Null<I18n>;
    private static var ru:Null<I18n>;

    public static function getI18n(locale:String):I18n {
        //if (eng == null || ru == null) {
          //  throw "Localization was not initialized";
       // }
        if (locale == "ru") {
            if(ru == null){
                ru = new I18n();
                ru.loadFromString(haxe.Resource.getString("localization_ru"));
            }
            return ru;
        }
        if(eng == null){
            eng = new I18n();
            eng.loadFromString(haxe.Resource.getString("localization_eng"));
        }
        return eng;
    }
}
