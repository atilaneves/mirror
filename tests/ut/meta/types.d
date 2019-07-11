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


@("isStruct")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias structs = Filter!(isStruct, aggregates);
    static assert(is(structs == AliasSeq!(modules.types.String)), structs.stringof);
}


@("isInterface")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias interfaces = Filter!(isInterface, aggregates);
    static assert(is(interfaces == AliasSeq!(modules.types.Interface)), interfaces.stringof);
}


@("isClass")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias classes = Filter!(isClass, aggregates);
    alias expected = AliasSeq!(
        modules.types.Class,
        modules.types.AbstractClass,
        modules.types.MiddleClass,
        modules.types.LeafClass,
    );
    static assert(is(classes == expected), classes.stringof);
}


private string[] typeNames(alias module_)() {
    import std.meta: staticMap;
    enum name(alias Symbol) = __traits(identifier, Symbol);
    enum names = staticMap!(name, module_.Aggregates);
    return [names];
}
