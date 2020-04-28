module ut.rtti.any;


import ut;
import mirror.rtti;


@("types.int")
@safe pure unittest {
    auto extended = types!int;
}

@("rtti.null.object")
@safe pure unittest {
    static class Class {}
    Object o;
    Class c;

    with(types!Class) {
        rtti(o).shouldThrowWithMessage("Cannot get RTTI from null object");
        rtti(c).shouldThrowWithMessage("Cannot get RTTI from null object");
    }
}


@("rtti.unregistered")
@safe pure unittest {
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


@("typesVar")
@safe pure unittest {

    static struct Namespace {
        static immutable mirror.rtti.Types _types;
        mixin typesVar!(_types, int, double);
    }

    with(Namespace._types) {
        rtti(42).name.should == "int";
        rtti(33.3).name.should == "double";
    }
}
