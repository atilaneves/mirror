module python.conv.python_to_d;


import python: PyObject;
import std.traits: isIntegral;


T to(T)(PyObject* value) if(isIntegral!T) {
    import python: PyLong_AsLong;

   const ret = PyLong_AsLong(value);
   //if(ret > T.max || ret < T.min) throw new Exception("Overflow");

    return cast(T) ret;
}
