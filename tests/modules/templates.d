module ut.templates;


import ut;


@("types")
@safe pure unittest {
    import std.meta: staticMap;

    alias mod = ModuleTemplate!"modules.types";
    enum name(alias Symbol) = __traits(identifier, Symbol);
    enum names = staticMap!(name, mod.Types);
    [names].should == ["String"];
}
