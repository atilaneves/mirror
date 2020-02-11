module ut.issues;


import ut;
import mirror.meta;
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
