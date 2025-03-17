module ut.ctfe.reflection.traits;


import ut.ctfe.reflection;


@("isArithmetic")
@safe pure unittest {
    type!int.isArithmetic.should == true;
    type!float.isArithmetic.should == true;
    static struct Struct {}
    type!Struct.isArithmetic.should == false;
}
