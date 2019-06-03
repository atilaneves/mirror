module mirror.meta;


template Module(string moduleName) {
    import std.meta: Filter, staticMap, Alias;

    mixin(`import `, moduleName, `;`);
    alias mod = Alias!(mixin(moduleName));

    alias memberNames = __traits(allMembers, mod);

    private template member(string name) {
        import std.meta: Alias, AliasSeq;
        static if(__traits(compiles, Alias!(__traits(getMember, mod, name))))
            alias member = Alias!(__traits(getMember, mod, name));
        else
            alias member = AliasSeq!();
    }
    alias members = staticMap!(member, memberNames);

    private template isType(A...) if(A.length == 1) {
        enum isType = is(A[0]);
    }
    alias Types = Filter!(isType, members);
}
