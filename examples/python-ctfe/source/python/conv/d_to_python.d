module python.conv.d_to_python;


import python: PyObject;
import std.traits: isIntegral;


PyObject* toPython(T)(T value) if(isIntegral!T) {
    import python: PyLong_FromLong;
    return PyLong_FromLong(value);
}
