package shared;
class Assert {
	public static inline function assert(expr:Bool, ?msg:String) {
		//#if assert
			if (!expr) {
				if(msg == null){
					msg = "assert";
				}
				throw msg;
			}
		//#end
	}
}