module ut.templates;


import ut;


@("types")
@safe pure unittest {
    import std.meta: staticMap;

    alias mod = ModuleTemplate!"modules.types";
    enum Name(alias Symbol) = __traits(identifier, Symbol);
    enum ctNames = staticMap!(Name, mod.Types);
    string[] names;
    static foreach(name; ctNames) names ~= name;
    names.should == ["String"];
}
