module ut.rtti.any;


import ut;
import mirror.rtti;


@("types.int")
@safe pure unittest {
    auto extended = types!int;
}
