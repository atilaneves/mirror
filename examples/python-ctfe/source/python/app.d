import python;


private extern(C) PyObject* PyInit_libpython_wrap_ctfe() {

    import mirror: allModuleInfos;
    import core.runtime: rt_init;
    import std.stdio;

    try
        rt_init;
    catch(Exception _)
        return null;

    static PyModuleDef moduleDef;
    moduleDef = pyModuleDef(
        &"Das Module"[0],
        null, // doc
        -1, // size,
        null, // methodDefs
    );

    auto pyMod =  pyModuleCreate(&moduleDef);

    foreach(module_; allModuleInfos) {
        foreach(function_; module_.functionsByOverload) {
            addMethod(pyMod, function_);
        }
    }


    return pyMod;
}

void addMethod(PyObject* pyMod, in imported!"mirror.ctfe.reflection".Function function_) {
    import std.string: toStringz; // oops, GC
    import std.variant: Variant;
    import mirror.ctfe.reflection: Function;
    import python.conv.python_to_d;
    import python.conv.d_to_python;

    static extern(C) PyObject* wrappedCall(PyObject* self, PyObject* args) nothrow {
        try {
            auto variants = new Variant[PyTuple_Size(args)];
            foreach(const i, ref variant; variants)
                variant = toVariant(PyTuple_GetItem(args, i));
            auto capsule = PyCapsule_GetPointer(self, &"mirror.function"[0]);
            auto func = cast(Function) capsule;
            auto variantRet = func(variants);
            auto pythonRet = variantRet.toPython;
            return pythonRet;
        } catch(Exception e) {
            debug import std;
            debug writeln(e.msg);
            assert(0, "oopsie");
            return null;
        }
    }

    auto methodDef = new PyMethodDef( // oops, GC
        function_.identifier.toStringz,
        cast(PyCFunction) &wrappedCall, // function ptr
        METH_VARARGS | METH_KEYWORDS,
        null, // doc
    );

    auto capsule = PyCapsule_New(cast(void*) function_, &"mirror.function"[0], null);
    auto pyFunction = PyCFunction_NewEx(methodDef, capsule, null);
    PyModule_AddObject(pyMod, function_.identifier.toStringz, pyFunction);
}
