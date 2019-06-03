module mirror.meta;


template Module(string moduleName) {
    import std.meta: Filter, staticMap, Alias;

    mixin(`import `, moduleName, `;`);
    alias mod = Alias!(mixin(moduleName));

    enum wanted(string name) = name != "object" && name != "std";
    alias memberNames = Filter!(wanted, __traits(allMembers, mod));

    alias member(string name) = Alias!(mixin(name));
    alias Types = staticMap!(member, memberNames);
}
