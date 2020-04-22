import unit_threaded;


mixin runTestsMain!(
    "ut.issues",
    "ut.traits",
    "ut.meta.types",
    "ut.meta.variables",
    "ut.meta.functions",
    "ut.ctfe.reflection.types",
    "ut.ctfe.reflection.variables",
    "ut.ctfe.reflection.functions",
    "ut.ctfe.reflection.wrap",
    "ut.rtti.oop",
    "ut.rtti.any",
);
