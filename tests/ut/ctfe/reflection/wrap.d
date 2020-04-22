/**
   Tests for using CTFE mirror to wrap calling D code from a foreign language.
 */
module ut.ctfe.reflection.wrap;


import ut.ctfe.reflection;


@("blub.add1")
unittest {
    import blub;
    import std.format: format;

    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[0];

    enum mixinStr = blubWrapperMixin(add1);
    //pragma(msg, mixinStr);
    mixin(mixinStr);

    wrap(Blub(1), Blub(2)).should == Blub(4);
}


@("blub.concatFoo")
unittest {
    import blub;
    import std.format: format;

    enum mod = module_!"modules.functions";
    enum concatFoo = mod.functionsByOverload[10];

    enum mixinStr = blubWrapperMixin(concatFoo);
    //pragma(msg, mixinStr);
    mixin(mixinStr);

    wrap(Blub("hmmm"), Blub(42), Blub("quux")).should == Blub("hmmm42quuxfoo");
}


// Returns a string to be mixed in that defines a function `wrap`
// That calls converts blub types to D ones, calls `function_` then
// converts the result from D to blub.
private string blubWrapperMixin(Function function_) @safe pure {
    assert(__ctfe);

    import std.array: join;
    import std.algorithm: map;
    import std.range: iota;
    import std.format: format;

    string[] lines;

    static string argName(size_t i) {
        import std.conv: text;
        return text("arg", i);
    }

    const numParams = function_.parameters.length;
    // what goes in the function signature between the parens
    const wrapParams = numParams
        .iota
        .map!(i => "Blub " ~ argName(i))
        .join(", ")
        ;
    // the arguments to pass to the wrapped D function
    const dArgs = numParams
        .iota
        .map!(i => argName(i) ~ ".to!(" ~ function_.parameters[i].type.name ~ ")")
        .join(", ")
        ;

    return q{
        auto wrap(%s /*dArgs*/)
        {
            import blub: toBlub, to;
            %s  // import mixin
            return %s.toBlub;
        }
    }.format(
        wrapParams,
        function_.importMixin,
        function_.callMixin(dArgs)
    );
}
