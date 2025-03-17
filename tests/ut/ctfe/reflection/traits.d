module ut.ctfe.reflection.traits;


import ut.ctfe.reflection;


@("isArithmetic")
@safe pure unittest {
    type!int.isArithmetic.should == true;
    type!float.isArithmetic.should == true;
    static struct Struct {}
    type!Struct.isArithmetic.should == false;
}

@("isFloating")
@safe pure unittest {
    type!int.isFloating.should == false;
    type!float.isFloating.should == true;
}

@("isIntegral")
@safe pure unittest {
    type!int.isIntegral.should == true;
    type!float.isIntegral.should == false;
}

@("isScalar")
@safe pure unittest {
    type!int.isScalar.should == true;
    type!(int[4]).isScalar.should == false;
}

@("isUnsigned")
@safe pure unittest {
    type!int.isUnsigned.should == false;
    type!uint.isUnsigned.should == true;
}

@("isStaticArray")
@safe pure unittest {
    type!int.isStaticArray.should == false;
    type!(int[4]).isStaticArray.should == true;
}

@("isAssociativeArray")
@safe pure unittest {
    type!int.isAssociativeArray.should == false;
    type!(int[string]).isAssociativeArray.should == true;
}

@("isAbstractClass")
@safe pure unittest {
    type!int.isAbstractClass.should == false;
    static abstract class C {}
    type!C.isAbstractClass.should == true;
}

@("isFinalClass")
@safe pure unittest {
    type!int.isFinalClass.should == false;
    static final class C {}
    type!C.isFinalClass.should == true;
}

@("isCopyable")
@safe pure unittest {
    type!int.isCopyable.should == true;
    static struct S { @disable this(this); }
    type!S.isCopyable.should == false;
}

@("isPOD")
@safe pure unittest {
    type!int.isPOD.should == true;
    static struct S { ~this() { } }
    type!S.isPOD.should== false;
}

@("isZeroInit")
@safe pure unittest {
    type!int.isZeroInit.should == true;
    type!char.isZeroInit.should == false;
}

@("hasCopyConstructor")
@safe pure unittest {
    type!int.hasCopyConstructor.should == false;
    struct S { this(ref const(S)) {} }
    type!S.hasCopyConstructor.should == true;
}

@ShouldFail
@("hasMoveConstructor")
@safe pure unittest {
    type!int.hasMoveConstructor.should == false;
    struct S { this(S s) {} }
    type!S.hasMoveConstructor.should == true;
}

@("hasPostblit")
@safe pure unittest {
    type!int.hasPostblit.should == false;
    struct S { this(this) {} }
    type!S.hasPostblit.should == true;
}

@("aliasThis")
@safe pure unittest {
    type!int.aliasThis.shouldBeEmpty;
    struct S {
        string var;
        alias var this;
    }
    type!S.aliasThis.should == ["var"];
}

@("pointerBitmap")
@safe pure unittest {
    type!int.pointerBitmap.should == [int.sizeof, 0];
    struct S {
        long i;
        string s;
    }
    type!S.pointerBitmap.should == [S.sizeof, 4];
}

@("classInstanceSize")
@safe pure unittest {
    type!int.classInstanceSize.should == 0;
    class C {
        int i;
        string s;
    }
    type!C.classInstanceSize.should == 48;
}

@("classInstanceAlignment")
@safe pure unittest {
    type!int.classInstanceAlignment.should == 0;
    class C {
        int i;
        string s;
    }
    type!C.classInstanceAlignment.should == 8;
}


@("isDisabled")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const struct_ = mod.aggregates[0];
    const disabled = struct_.functionsByOverload[0];
    disabled.fullyQualifiedName.should == "modules.traits.Struct.disabled";
    disabled.isDisabled.should == true;
    const notDisabled = struct_.functionsByOverload[1];
    notDisabled.fullyQualifiedName.should == "modules.traits.Struct.notDisabled";
    notDisabled.isDisabled.should == false;
}

@("virtualIndex")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const class_ = mod.aggregates[1];
    const bar = class_.functionsByOverload[1];
    bar.fullyQualifiedName.should == "modules.traits.Class.bar";
    bar.virtualIndex.should == 7;
}

@("isVirtualMethod")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const struct_ = mod.aggregates[0];
    const disabled = struct_.functionsByOverload[0];
    disabled.fullyQualifiedName.should == "modules.traits.Struct.disabled";
    disabled.isVirtualMethod.should == false;

    const class_ = mod.aggregates[1];
    const bar = class_.functionsByOverload[1];
    bar.fullyQualifiedName.should == "modules.traits.Class.bar";
    bar.isVirtualMethod.should == true;
}

@("isFinalAbstract")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const class_ = mod.aggregates[1];

    const abs = class_.functionsByOverload[2];
    abs.fullyQualifiedName.should == "modules.traits.Class.abstract_";
    abs.isAbstract.should == true;
    abs.isFinal.should == false;

    const fin = class_.functionsByOverload[3];
    fin.fullyQualifiedName.should == "modules.traits.Class.final_";
    fin.isAbstract.should == false;
    fin.isFinal.should == true;
}

@("isOverride")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const class_ = mod.aggregates[1];

    const abs = class_.functionsByOverload[2];
    abs.fullyQualifiedName.should == "modules.traits.Class.abstract_";
    abs.isOverride.should == false;

    const ovr = class_.functionsByOverload[4];
    ovr.fullyQualifiedName.should == "modules.traits.Class.overrideThis";
    ovr.isOverride.should == true;
}

@("isStatic")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const class_ = mod.aggregates[1];

    const abs = class_.functionsByOverload[2];
    abs.fullyQualifiedName.should == "modules.traits.Class.abstract_";
    abs.isStatic.should == false;

    const stc = class_.functionsByOverload[5];
    stc.fullyQualifiedName.should == "modules.traits.Class.static_";
    stc.isStatic.should == true;
}

@("isReturnOnStack")
@safe pure unittest {
    static immutable mod = module_!"modules.traits"();
    const struct_ = mod.aggregates[0];
    const notDisabled = struct_.functionsByOverload[1];
    notDisabled.fullyQualifiedName.should == "modules.traits.Struct.notDisabled";
    notDisabled.isReturnOnStack.should == false;

    const returnStruct = struct_.functionsByOverload[2];
    returnStruct.fullyQualifiedName.should == "modules.traits.Struct.returnStruct";
    returnStruct.isReturnOnStack.should == true;
}

@("isReturnOnStack")
@safe pure unittest {
    import mirror.ctfe.reflection: Function;

    static immutable mod = module_!"modules.traits"();
    const struct_ = mod.aggregates[0];
    {
        const notDisabled = struct_.functionsByOverload[1];
        notDisabled.fullyQualifiedName.should == "modules.traits.Struct.notDisabled";
        notDisabled.variadicStyle.should == Function.VariadicStyle.none;
    }

    {
        const stdarg = struct_.functionsByOverload[3];
        stdarg.fullyQualifiedName.should == "modules.traits.Struct.stdarg";
        stdarg.variadicStyle.should == Function.VariadicStyle.stdarg;
    }

    {
        const argptr = struct_.functionsByOverload[4];
        argptr.fullyQualifiedName.should == "modules.traits.Struct.argptr";
        argptr.variadicStyle.should == Function.VariadicStyle.argptr;
    }

    {
        const typesafe = struct_.functionsByOverload[5];
        typesafe.fullyQualifiedName.should == "modules.traits.Struct.typesafe";
        typesafe.variadicStyle.should == Function.VariadicStyle.typesafe;
    }
}
