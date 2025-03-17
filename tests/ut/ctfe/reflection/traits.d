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

@safe pure unittest {
    type!int.isAbstractClass.should == false;
    static abstract class C {}
    type!C.isAbstractClass.should == true;
}
