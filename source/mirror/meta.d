module mirror.meta;


template ModuleTemplate(string name) {
    import std.meta: Filter, staticMap, Alias;

    mixin(`import `, name, `;`);
    alias mod = Alias!(mixin(name));

    enum notObject(string name) = name != "object";
    alias memberNames = Filter!(notObject, __traits(allMembers, mod));

    alias member(string name) = Alias!(mixin(name));
    alias Types = staticMap!(member, memberNames);
}
