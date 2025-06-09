module ut.rtti.any;


import ut;
import mirror.rtti;


@("types.fundamental")
@safe unittest {
    with(types!(int, double)) {
        rtti(42).name.should == "int";
        rtti(33.3).name.should == "double";
    }
}

@("rtti.null.object")
@safe unittest {
    static class Class {}
    static interface Interface{}
    Object o;
    Class c;
    Interface i;

    with(types!Class) {
        rtti(o).shouldThrowWithMessage("Cannot get RTTI from null object");
        rtti(c).shouldThrowWithMessage("Cannot get RTTI from null object");
        rtti(i).shouldThrowWithMessage("Cannot get RTTI from null object");
    }
}


@("rtti.unregistered")
@safe unittest {
    static class Class {}
    enum testName = __traits(identifier, __traits(parent, {}));
    enum prefix = __MODULE__ ~ "." ~ testName ~ ".";

    with(types!()) {
        rtti(new Class).shouldThrowWithMessage(
            "Cannot get RTTI for unregistered type " ~
            prefix ~ "Class"
            );
    }
}
