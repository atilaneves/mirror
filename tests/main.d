import unit_threaded;


mixin runTestsMain!(
    "ut.meta.types",
    "ut.ctfe.types",
    "ut.meta.variables",
    "ut.ctfe.variables",
    "ut.meta.functions",
);
