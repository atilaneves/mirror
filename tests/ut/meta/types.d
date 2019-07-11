module ut.meta.types;


import ut.meta;


@("empty")
@safe pure unittest {
    alias mod = Module!"modules.empty";
    typeNames!mod.should == [];
}


@("imports")
@safe pure unittest {
    alias mod = Module!"modules.imports";
    typeNames!mod.should == [];
}


@("types")
@safe pure unittest {
    alias mod = Module!"modules.types";
    typeNames!mod.shouldBeSameSetAs(
        [
            "String",
            "Enum",
            "Class",
            "Interface",
            "AbstractClass",
            "MiddleClass",
            "LeafClass",
        ]
    );
}


@("problems")
@safe pure unittest {
    alias mod = Module!"modules.problems";
    typeNames!mod.should == [];
}


@("variables")
@safe pure unittest {
    alias mod = Module!"modules.variables";
    typeNames!mod.should == ["Struct"];
}


@("isEnum")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias enums = Filter!(isEnum, aggregates);
    static assert(is(enums == AliasSeq!(modules.types.Enum)), enums.stringof);
}


private string[] typeNames(alias module_)() {
    import std.meta: staticMap;
    enum name(alias Symbol) = __traits(identifier, Symbol);
    enum names = staticMap!(name, module_.Aggregates);
    return [names];
}
