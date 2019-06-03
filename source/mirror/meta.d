module mirror.meta;


template Module(string moduleName) {
    import std.meta: Filter, staticMap, Alias;

    mixin(`import `, moduleName, `;`);
    alias mod = Alias!(mixin(moduleName));

    enum notObject(string name) = name != "object";
    alias memberNames = Filter!(notObject, __traits(allMembers, mod));

    alias member(string name) = Alias!(mixin(name));
    alias Types = staticMap!(member, memberNames);
}
