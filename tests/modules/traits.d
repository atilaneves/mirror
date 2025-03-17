module modules.traits;

struct Struct {
    @disable void disabled() {}
    int notDisabled() { return 42; }
    static struct ReturnStruct {
        int[20] ints;
    }
    ReturnStruct returnStruct() { return ReturnStruct(); }
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
