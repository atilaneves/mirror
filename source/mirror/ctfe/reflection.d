/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection;


/*
  TODO:

  * Add static constructors to the module struct.

  * When doing aggregates, include function return types and
    parameters, see the old `functions.allAggregates` test.

  * Add visibility to struct fields.

  * Add types to test structs/classes/etc.

  * Add enums to test structs/classes/etc.

  * Visibility for variables/fields?

  * Fix default values.
*/


Module module_(string moduleName)() {

    mixin(`static import `, moduleName, `;`);
    alias module_ = mixin(moduleName);
    auto mod = reflect!(module_, Module);
    mod.allAggregates = mod.aggregates;  // FIXME

    return mod;
}

private auto reflect(alias container, T)() {
    import std.traits: moduleName;

    Variable[] variables;
    Function[] functionsByOverload;
    OverloadSet[] functionsBySymbol;
    Aggregate[] aggregates;
    UnitTest[] unitTests;

    static foreach(memberName; __traits(allMembers, container)) {{

        // although this is fine even for a class, trying to pass this in
        // as a template parameter will fail. Using `agg.init` doesn't
        // work either.
        alias member = __traits(getMember, container, memberName);

        static if(is(typeof(member) == function) && isRegularFunction(memberName)) {
            functionsByOverload ~= overloads  !(container, member, memberName);
            functionsBySymbol   ~= overloadSet!(container, member, memberName);
        } else static if(is(member) && isUDT!member)
            aggregates ~= reflect!(member, Aggregate);
        // the first part only works for aggregates and isSymbolVariable only works for modules
        else static if((is(typeof(container.init)) && !is(TypeOf!member == function)) || isSymbolVariable!member) {
            variables ~= Variable(
                Type(__traits(fullyQualifiedName, typeof(member))),
                __traits(fullyQualifiedName, member),
            );
        }
    }}

    auto ret = new T;
    ret.fullyQualifiedName = __traits(fullyQualifiedName, container);
    ret.moduleName = moduleName!container;
    ret.parent = __traits(fullyQualifiedName, __traits(parent, container));

    static if(__traits(hasMember, T, "kind"))
        ret.kind = Aggregate.toKind!container;
    ret.variables ~= variables;
    ret.aggregates = aggregates;
    ret.functionsByOverload = functionsByOverload;
    ret.functionsBySymbol = functionsBySymbol;

    static foreach(i, ut; __traits(getUnitTests, container)) {{
        auto unitTest = new UnitTest;
        unitTest.fullyQualifiedName = __traits(fullyQualifiedName, ut);
        unitTest.parent = __traits(fullyQualifiedName, __traits(parent, ut));
        unitTest.moduleName = moduleName!ut;
        unitTest.index = i;
        ret.unitTests ~= unitTest;
    }}


    return ret;
}

private template TypeOf(alias T) {
    static if(is(T))
        alias TypeOf = T;
    else static if(__traits(compiles, typeof(T)))
        alias TypeOf = typeof(T);
    else
        alias TypeOf = void;
}

private OverloadSet overloadSet(alias parent, alias symbol, string memberName)() {
    auto functions = overloads!(parent, symbol, memberName);
    return OverloadSet(__traits(fullyQualifiedName, parent) ~ "." ~ memberName, functions);
}

private Function[] overloads(alias parent, alias symbol, string memberName)() {
    import std.traits: moduleName;
    import std.algorithm: countUntil;

    Function[] ret;

    static foreach(i, overload; __traits(getOverloads, parent, memberName)) {{

        static if(is(typeof(overload) R == return))
            enum returnType = Type(__traits(fullyQualifiedName, R));
        else
            static assert(false, "Cannot get return type of " ~ __traits(fullyQualifiedName, overload));

        Parameter[] parameters;
        static if(is(typeof(overload) Ps == __parameters)) {
            static foreach(p; 0 .. Ps.length) {{

                static if(is(typeof(__traits(identifier, Ps[p .. p + 1]))))
                    enum paramIdentifier = __traits(identifier, Ps[p .. p + 1]);
                else
                    enum paramIdentifier = Ps[i].stringof;

                enum paramString = Ps[p .. p + 1].stringof;
                enum assignIndex = paramString.countUntil(`=`);
                static if(assignIndex == -1)
                    enum default_ = "";
                else {
                    // paramString will be something like:
                    // `(T id = val)`
                    // we want default_ in this case to be "val"
                    static assert(paramString[assignIndex + 1] == ' ');
                    enum default_ = paramString[assignIndex + 2 .. $-1];
                }

                parameters ~= Parameter(
                    Type(__traits(fullyQualifiedName, Ps[p])),
                    paramIdentifier,
                    phobosPSC([__traits(getParameterStorageClasses, overload, p)]),
                    default_,
                );
            }}
        } else
            static assert(false, "Cannot get parameters of " ~ __traits(fullyQualifiedName, overload));

        auto func = new Function;
        func.fullyQualifiedName = __traits(fullyQualifiedName, parent) ~ "." ~ memberName;
        func.moduleName = moduleName!parent;
        func.parent = __traits(fullyQualifiedName, parent);
        func.overloadIndex = i;
        func.returnType = returnType;
        func.parameters = parameters;
        func.visibilityStr = __traits(getVisibility, overload);
        func.linkageStr = __traits(getLinkage, overload);
        ret ~= func;
    }}

    return ret;
}


private bool isRegularFunction(in string memberName) @safe pure nothrow {
    import std.algorithm: startsWith;
        return
            !memberName.startsWith("_sharedStaticCtor") &&
            !memberName.startsWith("_staticCtor");
}

private bool isUDT(Type)() {
    return
        is(Type == enum) ||
        is(Type == struct) ||
        is(Type == class) ||
        is(Type == interface) ||
        is(Type == union)
        ;
}

// look ma, no templates
private auto phobosPSC(in string[] storageClasses) @safe pure nothrow {
    import std.traits: PSC = ParameterStorageClass;

    auto ret = PSC.none;

    foreach(storageClass; storageClasses) {
        final switch(storageClass) with(PSC) {
            case "scope":  ret |= scope_;  break;
            case "in":     ret |= in_;     break;
            case "out":    ret |= out_;    break;
            case "ref":    ret |= ref_;    break;
            case "lazy":   ret |= lazy_;   break;
            case "return": ret |= return_; break;
        }
    }

    return ret;
}

abstract class Member {
    string fullyQualifiedName;
    string moduleName;
    string parent;

    final string identifier() @safe pure scope const {
        import std.string: split;
        return fullyQualifiedName.split(".")[$-1];
    }

    final string importMixin() @safe pure scope const {
        return `static import ` ~ moduleName ~ `;`;
    }

    abstract string aliasMixin() @safe pure scope const;
    // abstract Visibility visibility() @safe pure scope const;
    // abstract Linkage linkage() @safe pure scope const;
}


class Container: Member {

    Function[] functionsByOverload;
    OverloadSet[] functionsBySymbol;
    Aggregate[] aggregates; /// only the ones defined in the module.
    Variable[] variables;
    UnitTest[] unitTests;
}

class Module: Container {

    Aggregate[] allAggregates; /// includes all function return types.

    override string aliasMixin() @safe pure scope const {
        return fullyQualifiedName;
    }
}

class Aggregate: Container {

    enum Kind {
        enum_,
        struct_,
        class_,
        interface_,
        union_,
    }

    Kind kind;

    static Kind toKind(T)() {
        with(Kind) {
            static foreach(k; ["enum", "struct", "class", "interface", "union"]) {
                static if(mixin(`is(T == `, k, `)`))
                    return mixin(k ~ "_");
            }
        }
    }

    override string aliasMixin() @safe pure scope const {
        return `__traits(getMember, ` ~ parent ~ `, "` ~ identifier ~ `")`;
    }
}

struct OverloadSet {
    string fullyQualifiedName;
    Function[] overloads;

    invariant { assert(overloads.length > 0); }

    string importMixin() @safe pure const scope {
        return overloads[0].importMixin;
    }
}

class Function: Member {
    size_t overloadIndex;
    Type returnType;
    Parameter[] parameters;
    string visibilityStr;
    string linkageStr;

    override string aliasMixin() @safe pure scope const {
        import std.conv: text;
        return text(`__traits(getOverloads, `,  this.parent,  `, "`,  this.identifier,  `")[`, overloadIndex, `]`);
    }

    Visibility visibility() @safe pure scope const {
        switch(visibilityStr) with(Visibility) {
            default: throw new Exception("Unknown visibility " ~ visibilityStr);
                static foreach(vis; ["public", "private", "protected", "export", "package"]) {
                case vis: return mixin(vis ~ "_");
            }
       }
    }

    Linkage linkage() @safe pure scope const {
        switch(linkageStr) with(Linkage) {
            default: throw new Exception("Unknown linkage " ~ linkageStr);
            case "D": return D;
            case "C": return C;
            case "C++": return Cplusplus;
            case "Windows": return Windows;
            case "ObjectiveC": return ObjectiveC;
            case "System": return System;
        }
    }
}


struct Type {
    string fullyQualifiedName;
}


struct Parameter {
    import std.traits: PSC = ParameterStorageClass;

    Type type;
    string identifier;
    PSC storageClass;
    string default_;
}

enum Visibility {
    public_,
    private_,
    protected_,
    export_,
    package_,
}


enum Linkage {
    D,
    C,
    Cplusplus,
    Windows,
    ObjectiveC,
    System,
}


struct Variable {
    Type type;
    string fullyQualifiedName;
}

private bool isSymbolVariable(alias symbol)() {
    return
            is(typeof(symbol))
        && !is(typeof(symbol) == function)
        && !is(typeof(symbol) == void)  // can happen with templates
        && is(typeof(symbol.init))
        ;
}

private bool isTypeVariable(T)() {
    return
        is(T)
        && !is(T == function)
        && !is(T == void)  // can happen with templates
        && is(typeof(T.init))
        ;
}


string moduleName(T)(auto ref T obj) {
    import std.string: split, join;
    return obj.fullyQualifiedName.split(".")[0 .. $-1].join(".");
}

string identifier(T)(auto ref T obj) {
    import std.string: split, join;
    return obj.fullyQualifiedName.split(".")[$-1];
}


class UnitTest: Member {
    size_t index;

    override string aliasMixin() @safe pure nothrow scope const {
        import std.conv: text;
        return text(`__traits(getUnitTests, `, parent, `)[`, index, `]`);
    }
}
