module modules.traits;

struct Struct {
    @disable void disabled() {}
    void notDisabled() {}
}

class Class: Base {
    void foo() {}
    void bar() {}
    abstract void abstract_();
    final void final_() {}
    override void overrideThis() {}
    static void static_() {}
}

class Base {
    void overrideThis() {}
}
