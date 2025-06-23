module python.conv.d_to_python;


import python: PyObject;
import std.traits: isIntegral;
import std.variant: Variant;


PyObject* toPython(T)(T value) if(isIntegral!T) {
    import python: PyLong_FromLong;
    return PyLong_FromLong(value);
}

PyObject* toPython(Variant variant) {
    import python: PyLong_FromLong;
    return PyLong_FromLong(variant.get!long);
}
