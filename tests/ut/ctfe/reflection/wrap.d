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

// Returns a string to be mixed in that defines a function `wrap`
// That calls converts blub types to D ones, calls `function_` then
// converts the result from D to blub.
private string blubWrapperMixin(Function function_) @safe pure {
    assert(__ctfe);

    import std.array: join;
    import std.algorithm: map;
    import std.range: iota;
    import std.format: format;
    import std.conv: text;

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
        .map!(i => argName(i) ~ ".to!(" ~ function_.parameters[i].type.fullyQualifiedName ~ ")")
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
        text(function_.fullyQualifiedName, `(`, dArgs, `)`),
    );
}
