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
