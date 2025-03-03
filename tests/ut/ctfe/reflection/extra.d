module ut.ctfe.reflection.extra;


import ut.ctfe.reflection;


@("unitTests")
@safe pure unittest {
    import std.algorithm: map;

    enum mod = module_!"modules.extra"();

    mod.unitTests.map!(a => a.fullyQualifiedName).should == [
        "modules.extra.__unittest_L3_C12",
        "modules.extra.__unittest_L4_C12",
    ];

    enum failingUtInfo = mod.unitTests[1];
    mixin(failingUtInfo.importMixin);
    alias failingUt = mixin(failingUtInfo.aliasMixin);
    failingUt().shouldThrowWithMessage("oh noes");

    mod.aggregates[0].unitTests.map!(a => a.fullyQualifiedName).should == [
        "modules.extra.Struct.__unittest_L7_C16",
    ];
    enum structUtInfo = mod.aggregates[0].unitTests[0];
    alias structUt = mixin(structUtInfo.aliasMixin);
    structUt.shouldThrowWithMessage("oh noes from struct");
}
