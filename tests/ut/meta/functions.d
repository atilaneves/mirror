module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;


@("foo")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    static import modules.functions;
    static assert(__traits(
                      isSame,
                      mod.Functions,
                      AliasSeq!(
                          modules.functions.add1,
                      )
                  ),
                  mod.Functions.stringof,
    );
}
