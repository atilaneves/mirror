module mirror.meta;


template Module(string moduleName) {
    import std.meta: Filter, staticMap, Alias, AliasSeq;
    import std.traits: isSomeFunction, isType;

    mixin(`import `, moduleName, `;`);
    private alias mod = Alias!(mixin(moduleName));

    private alias memberNames = __traits(allMembers, mod);

    private template member(string name) {
        import std.meta: Alias, AliasSeq;
        static if(__traits(compiles, Alias!(__traits(getMember, mod, name))))
            alias member = Alias!(__traits(getMember, mod, name));
        else
            alias member = AliasSeq!();
    }
    private alias members = staticMap!(member, memberNames);
    private enum notPrivate(alias T) = __traits(getProtection, T) != "private";
    private alias publicMembers = Filter!(notPrivate, members);

    alias Types = Filter!(isType, publicMembers);
    private enum isVariable(alias member) = is(typeof(member));
    private enum toVariable(alias member) = Variable!(typeof(member))(__traits(identifier, member));
    alias Variables = staticMap!(toVariable, Filter!(isVariable, publicMembers));

    private alias overloads(alias F) = __traits(getOverloads, mod, __traits(identifier, F));
    alias Functions = staticMap!(overloads, Filter!(isSomeFunction, publicMembers));
}


struct Variable(T) {
    alias Type = T;
    string name;
}
