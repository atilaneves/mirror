module modules.traits;

struct Struct {
    @disable void disabled() {}
    int notDisabled() @safe @nogc pure nothrow const { return 42; }
    static struct ReturnStruct {
        int[20] ints;
    }
    ReturnStruct returnStruct() { return ReturnStruct(); }
    import core.stdc.stdarg; // annoying editor error otherwise
    extern(C) void stdarg(int, ...) {}
    void argptr(...) {}
    void typesafe(int[]...) {}
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

@__future int theFuture;
deprecated("cos I said so") int theDeprecated;

enum modulesTraitsFile = __FILE__;

@(42, "a string", Struct(), Struct, Class, twice, typeof(&twice))
int intWithUDAs;

int twice(int i) {
    return i * 2;
}
