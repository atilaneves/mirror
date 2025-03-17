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
