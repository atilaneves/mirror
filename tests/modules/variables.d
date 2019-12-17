module modules.variables;

int gInt;
immutable gDouble = 33.3;

struct Struct {}

Struct gStruct;

enum CONSTANT_INT = 42;
enum CONSTANT_STRING = "foobar";

immutable int gImmutableInt = 77;


// just to check that this doesn't cause problems
auto templateFunction(T...)(T stuff) {
    ubyte[16] ret;
    return ret;
}
