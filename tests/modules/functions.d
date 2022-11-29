module modules.functions;
static import modules.templates;


int add1(int i, int j) {
    return i + j + 1;
}


double add1(double d0, double d1) {
    return d0 + d1 + 1;
}


double withDefault(double fst, double snd = 33.3) {
    return fst + snd;
}


void storageClasses(
    int normal,
    return scope int* returnScope,
    out int out_,
    ref int ref_,
    lazy int lazy_,
    )
{

}


export void exportedFunc() {}

extern(C) void externC() {}

extern(C++) void externCpp() {}


alias identityInt = modules.templates.identity!int;


shared static this() { }

static this() { }


unittest {}


auto voldemort(int i) {
    static struct Voldemort {
        int i;
    }

    return Voldemort(i);
}


auto voldemortArray(int i) {

    static struct DasVoldemort {
        int i;
    }

    return [DasVoldemort(i)];
}


string concatFoo(string s0, int i, string s1) {
    import std.conv: text;
    return s0 ~ i.text ~ s1 ~ "foo";
}
