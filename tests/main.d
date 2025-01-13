import unit_threaded;


mixin runTestsMain!(
    "ut.issues",
    "ut.meta.traits",
    "ut.meta.reflection.types",
    "ut.meta.reflection.variables",
    "ut.meta.reflection.functions",
    "ut.ctfe.reflection.types",
    "ut.ctfe.reflection.variables",
    "ut.ctfe.reflection.functions",
    "ut.ctfe.reflection.functions2",
    "ut.ctfe.reflection.wrap",
    "ut.rtti.oop",
    "ut.rtti.any",
);
