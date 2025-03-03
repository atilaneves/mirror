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

  * Add unit tests to the module struct.

  * When doing aggregates, include function return types and
    parameters, see the old `functions.allAggregates` test.

  * Add visibility to struct fields.

  * Add types to test structs/classes/etc.

  * Add enums to test structs/classes/etc.

  * Visibility for variables/fields?

  * Resolve inconsistency between module-level variables having FQNs
    and aggregate-level ones not.

  * Make sure everything that can be reflected on can be accessed by
    its symbol, so that all traits work. That is: have
    `mixin(foo.symbolMixin)` always work (it doesn't right now for
    methods).

  * Fix default values.
*/


Module module_(string moduleName)() {

    import std.algorithm: countUntil;

    Module mod;
    mod.identifier = moduleName;

    mixin(`static import `, moduleName, `;`);
    alias module_ = mixin(moduleName);

    static foreach(memberName; __traits(allMembers, module_)) {{

        alias symbol = __traits(getMember, module_, memberName);

        static if(isVisible!symbol) {

            static if(is(typeof(symbol) == function) && isRegularFunction(memberName)) {
                mod.functionsByOverload ~= overloads  !(module_, symbol, memberName);
                mod.functionsBySymbol   ~= overloadSet!(module_, symbol, memberName);
            } else static if(is(symbol) && isUDT!symbol)
                mod.aggregates ~= aggregate!symbol;
            else static if(isSymbolVariable!symbol) {
                mod.variables ~= Variable(
                    Type(__traits(fullyQualifiedName, typeof(symbol))),
                    __traits(fullyQualifiedName, symbol),
                );
            }
        }
    }}

    mod.allAggregates = mod.aggregates;  // FIXME

    return mod;
}

private template TypeOf(alias T) {
    static if(is(T))
        alias TypeOf = T;
    else static if(__traits(compiles, typeof(T)))
        alias TypeOf = typeof(T);
    else
        alias TypeOf = void;
}

private bool isVisible(alias symbol)() {
    static if(__traits(compiles, __traits(getVisibility, symbol))) {
        enum vis = __traits(getVisibility, symbol);
        return vis == "public" || vis == "export";
    } else
        return true; // basic type (probably)
}

private Aggregate aggregate(alias agg)() {
    Variable[] fields;
    Function[] functionsByOverload;
    OverloadSet[] functionsBySymbol;

    static foreach(memberName; __traits(allMembers, agg)) {{
        // although this is fine even for a class, trying to pass this in
        // as a template parameter will fail. Using `agg.init` doesn't
        // work either.
        alias member = __traits(getMember, agg, memberName);

        // FIXME:
        // This is repeating the logic in `isVariable` but
        // I don't know how to pass this in to the
        // function.
        static if(is(typeof(agg.init)) && !is(TypeOf!member == function))
            fields ~= Variable(
                Type(__traits(fullyQualifiedName, TypeOf!member)),
                memberName,
            );
        else static if(is(typeof(member) == function)) {
            functionsByOverload ~= overloads  !(agg, member, memberName);
            functionsBySymbol   ~= overloadSet!(agg, member, memberName);
        }
    }}

    return Aggregate(
        __traits(fullyQualifiedName, agg),
        Aggregate.toKind!agg,
        fields,
        functionsByOverload,
        functionsBySymbol,
    );
}

private OverloadSet overloadSet(alias parent, alias symbol, string memberName)() {
    auto functions = overloads!(parent, symbol, memberName);
    return OverloadSet(__traits(fullyQualifiedName, parent) ~ "." ~ memberName, functions);
}

private Function[] overloads(alias parent, alias symbol, string memberName)() {
    import std.traits: moduleName;
    import std.algorithm: countUntil;

    Function[] ret;

    // FIXME
    //static assert(__traits(identifier, symbol) == memberName);

    static foreach(i, overload; __traits(getOverloads, parent, memberName)) {{

        static if(is(typeof(overload) R == return))
            enum returnType = Type(__traits(fullyQualifiedName, R));
        else
            static assert(false, "Cannot get return type of " ~ __traits(identifier, overload));

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
            static assert(false, "Cannot get parameters of " ~ __traits(identifier, overload));

        ret ~= Function(
            moduleName!parent,
            __traits(fullyQualifiedName, parent),
            __traits(fullyQualifiedName, parent) ~ "." ~ memberName,
            i,
            returnType,
            parameters,
            __traits(getVisibility, overload),
            __traits(getLinkage, overload),
        );
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

struct Module {
    string identifier;
    Function[] functionsByOverload;
    OverloadSet[] functionsBySymbol;
    Aggregate[] aggregates;     /// only the ones defined in the module.
    Aggregate[] allAggregates;  /// includes all function return types.
    Variable[] variables;
}

struct OverloadSet {
    string fullyQualifiedName;
    Function[] overloads;

    invariant { assert(overloads.length > 0); }

    string importMixin() @safe pure nothrow const scope {
        return overloads[0].importMixin;
    }
}

struct Function {
    string moduleName;
    string parent;
    /**
       Do NOT use this to get the symbol, it will fail for overloads
       other than the first one.
     */
    string fullyQualifiedName;
    size_t overloadIndex;
    Type returnType;
    Parameter[] parameters;
    string visibilityStr;
    string linkageStr;

    string importMixin() @safe pure nothrow scope const {
        return "static import " ~ this.moduleName ~ ";";
    }

    string symbolMixin() @safe pure nothrow scope const {
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

struct Aggregate {

    enum Kind {
        enum_,
        struct_,
        class_,
        interface_,
        union_,
    }

    string fullyQualifiedName;
    Kind kind;
    Variable[] fields;
    Function[] functionsByOverload;
    OverloadSet[] functionsBySymbol;

    static Kind toKind(T)() {
        with(Kind) {
            static foreach(k; ["enum", "struct", "class", "interface", "union"]) {
                static if(mixin(`is(T == `, k, `)`))
                    return mixin(k ~ "_");
            }
        }
    }
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
