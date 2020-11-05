package shared.base.struct;

import shared.base.enums.ContextName;
class ContextStruct {
    public var name(default, null):ContextName;
    public var lifespan(default, null):Int;
    public var parameters(default, null):Null<Dynamic>;

    public function new(name:ContextName, lifespan:Int, parameters:Null<Dynamic>) {
        this.name = name;
        this.lifespan = lifespan;
        this.parameters = parameters;
    }
}
