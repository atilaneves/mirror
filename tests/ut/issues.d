module ut.issues;


import ut;
import mirror.meta.reflection;
import mirror.meta.traits;
import std.meta: AliasSeq;


@("1")
@safe pure unittest {
    static import modules.issues;
    alias mod = Module!"modules.issues";
    // pragma(msg, mod.AllAggregates);
    shouldEqual!(
        mod.AllAggregates,
        AliasSeq!(
            modules.issues.Issue1,
            modules.issues.CtorProtectionsStruct,
            modules.issues.Issue9,
            modules.issues.Issue1.String,
        ),
    );
}


@("MemberFunctionsByOverload.class.templateAlias")
@safe @nogc pure unittest {

    static class Class {
        T default_(T)() { return T.init; }  // both this and the alias below
        alias defaultInt = default_!int;    // are needed to mimic a bug
    }

    alias fs = MemberFunctionsByOverload!Class;  // should compile
}


@("MemberFunctionsByOverloads.union")
@safe @nogc pure unittest {
    static union Union {
        int constant() @safe @nogc pure nothrow const { return 42; }
    }
    alias fs = MemberFunctionsByOverload!Union;
    static assert(fs.length == 1);
}
