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
