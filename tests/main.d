import unit_threaded;


mixin runTestsMain!(
    "ut.issues",
    "ut.traits",
    "ut.meta.types",
    "ut.ctfe.types",
    "ut.meta.variables",
    "ut.ctfe.variables",
    "ut.meta.functions",
    "ut.ctfe.functions",
    "ut.ctfe.wrap",
    "ut.rtti.oop",
);
