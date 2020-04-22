module ut.rtti.any;


import ut;
import mirror.rtti;


@("extendRTTI.int")
@safe pure unittest {
    auto extended = extendRTTI!int;
}
