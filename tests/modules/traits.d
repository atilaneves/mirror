module modules.traits;

struct Struct {
    @disable void disabled() {}
    void notDisabled() {}
}

class Class {
    void foo() {}
    void bar() {}
}
