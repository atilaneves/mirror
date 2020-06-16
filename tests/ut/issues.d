module ut.issues;


import ut;
import mirror.meta.reflection;
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

    import mirror.meta.traits: MemberFunctionsByOverload;

    static class Class {
        T default_(T)() { return T.init; }  // both this and the alias below
        alias defaultInt = default_!int;    // are needed to mimic a bug
    }

    alias fs = MemberFunctionsByOverload!Class;  // should compile
}
