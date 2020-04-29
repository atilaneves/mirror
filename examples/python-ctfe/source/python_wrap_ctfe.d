import mirror.ctfe.reflection;


import python;


extern(C) export PyObject* PyInit_python_wrap_ctfe() {
    enum numMethods = 1;
    static PyMethodDef[numMethods + 1] methodDefs;
    methodDefs[0] = pyMethodDef!("add1")(&add1);

    static PyModuleDef moduleDef;
    moduleDef = pyModuleDef("python_wrap_ctfe".ptr, null /*doc*/, -1 /*size*/, methodDefs.ptr);

    return pyModuleCreate(&moduleDef);
}


private extern(C) PyObject* add1(PyObject* self, PyObject *args) nothrow {

    import python.conv.python_to_d: to;
    import python.conv.d_to_python: toPython;
    import std.conv: text;
    import std.string: toStringz;

    if(PyTuple_Size(args) != 2) {
        PyErr_SetString(PyExc_TypeError, text("Must use 2 arguments, not ", PyTuple_Size(args)).toStringz);
        return null;
    }

    auto arg0 = PyTuple_GetItem(args, 0);
    auto arg1 = PyTuple_GetItem(args, 1);

    return (arg0.to!int + arg1.to!int + 1).toPython;
}
