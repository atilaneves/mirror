module modules.traits;

struct Struct {
    @disable void disabled() {}
    void notDisabled() {}
}

class Class {
    void foo() {}
    void bar() {}
    abstract void abstract_();
    final void final_();
}
