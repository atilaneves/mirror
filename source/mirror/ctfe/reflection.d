/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection;


/*
  TODO:

  * Add types to test structs/classes/etc.

  * Add enums to test structs/classes/etc.

  * Fix default values.

  * Add static constructors to the module struct. This is going to be
    hard to test since by definition all of them will have already run
    before main.

  * When doing aggregates, include function return types and
    parameters, see the old `functions.allAggregates` test.
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
        else static if((is(typeof(container.init)) && !is(TypeOf!member == function)) ||
                       isSymbolVariable!member)
        {
            auto var = newMember!(container, memberName, Variable);
            var.type = type!(typeof(member));

            variables ~= var;
        }
    }}

    auto ret = newMember!(container, T);

    static if(__traits(hasMember, T, "kind"))
        ret.kind = Aggregate.toKind!container;

    ret.variables ~= variables;
    ret.aggregates = aggregates;
    ret.functionsByOverload = functionsByOverload;
    ret.functionsBySymbol = functionsBySymbol;

    static foreach(i, ut; __traits(getUnitTests, container)) {{
        auto unitTest = newMember!(ut, UnitTest);
        unitTest.index = i;
        ret.unitTests ~= unitTest;
    }}

    return ret;
}

private auto newMember(alias member, T)() {
    mixin(newMemberImpl);
}

private auto newMember(alias parent, string identifier, T)() {
    alias member = __traits(getMember, parent, identifier);
    mixin(newMemberImpl);
}

private string newMemberImpl() @safe pure {
    return q{
        import std.traits: moduleName;
        auto ret = new T;
        ret.fullyQualifiedName = __traits(fullyQualifiedName, member);
        ret.parent = __traits(fullyQualifiedName, __traits(parent, member));
        ret.moduleName = moduleName!member;
        ret.visibilityStr = __traits(getVisibility, member);
        static if(__traits(compiles, __traits(getLinkage, member)))
            ret.linkageStr = __traits(getLinkage, member);
        static if(__traits(compiles, __traits(isNested, member)))
        ret.isNested = __traits(isNested, member);
        ret.isFuture = __traits(isFuture, member);
        ret.isDeprecated = __traits(isDeprecated, member);
        ret.isTemplate = __traits(isTemplate, member);
        ret.isModule = __traits(isModule, member);
        static if(__traits(compiles, __traits(getLocation, member))) {
            enum loc = __traits(getLocation, member);
            ret.location = Location(loc[0], loc[1], loc[2]);
        }

        static foreach(uda; __traits(getAttributes, member)) {
            static if(is(uda)) {
                ret.UDAs ~= TypeUDA.create!uda;
            } else static if(__traits(compiles, uda.init)) {
                ret.UDAs ~= new ValueUDA(uda);
            } else {
                ret.UDAs ~= SymbolUDA.create!uda;
            }
        }

        return ret;
    };
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
            enum returnType = type!R;
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
                    type!(Ps[p]),
                    paramIdentifier,
                    phobosPSC([__traits(getParameterStorageClasses, overload, p)]),
                    default_,
                );
            }}
        } else
            static assert(false, "Cannot get parameters of " ~ __traits(fullyQualifiedName, overload));

        auto func = newMember!(overload, Function);
        // override the fqn from `newMember` above since we want overriden methods
        func.fullyQualifiedName = __traits(fullyQualifiedName, parent) ~ "." ~ memberName;
        func.overloadIndex = i;
        func.returnType = returnType;
        func.parameters = parameters;
        func.isDisabled = __traits(isDisabled, overload);
        func.virtualIndex = __traits(getVirtualIndex, overload);
        func.isVirtualMethod = __traits(isVirtualMethod, overload);
        func.isAbstract = __traits(isAbstractFunction, overload);
        func.isFinal = __traits(isFinalFunction, overload);
        func.isOverride = __traits(isOverrideFunction, overload);
        func.isStatic = __traits(isStaticFunction, overload);
        func.isReturnOnStack = __traits(isReturnOnStack, overload);
        func.variadicStyle = mixin(`Function.VariadicStyle.`, __traits(getFunctionVariadicStyle, overload));
        func.attributes = [ __traits(getFunctionAttributes, overload) ];

        static if(__traits(compiles, () @safe { void* p = &overload; }))
            func.caller = &Caller!overload.impl;
        else static if(!__traits(isModule, __traits(parent, overload)) &&
                       !__traits(isAbstractFunction, overload))
            func.caller = &Caller!overload.impl;

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
    string visibilityStr;
    string linkageStr;
    bool isNested;
    bool isFuture;
    bool isDeprecated;
    bool isTemplate;
    bool isModule;
    Location location;
    UDA[] UDAs;

    abstract string aliasMixin() @safe pure scope const;

    final string identifier() @safe pure scope const {
        import std.string: split;
        return fullyQualifiedName.split(".")[$-1];
    }

    final string importMixin() @safe pure scope const {
        return `static import ` ~ moduleName ~ `;`;
    }

    final Visibility visibility() @safe pure scope const {
        switch(visibilityStr) with(Visibility) {
            default: throw new Exception("Unknown visibility " ~ visibilityStr ~ " " ~ typeid(this).toString);
                static foreach(vis; ["public", "private", "protected", "export", "package"]) {
                case vis: return mixin(vis ~ "_");
            }
       }
    }

    final Linkage linkage() @safe pure scope const {
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

    override string toString() @safe pure scope const  {
        import std.conv: text;
        return text(
            `Module(`,
            fullyQualifiedName, `, `,
            functionsByOverload, `, `,
            functionsBySymbol, `, `,
            aggregates, `, `,
            allAggregates, `, `,
            variables, `, `,
            unitTests, `, `,
            `)`
        );
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

    import std.variant: Variant;

    enum VariadicStyle {
        none,
        stdarg,
        argptr,
        typesafe,
    }

    size_t overloadIndex;
    Type returnType;
    Parameter[] parameters;
    bool isDisabled;
    size_t virtualIndex;
    bool isVirtualMethod;
    bool isAbstract;
    bool isFinal;
    bool isOverride;
    bool isStatic;
    bool isReturnOnStack;
    VariadicStyle variadicStyle;
    string[] attributes;
    alias Caller = Variant function(void*, Variant[]);
    Caller caller;

    override string aliasMixin() @safe pure scope const {
        import std.conv: text;
        return text(`__traits(getOverloads, `,  this.parent,  `, "`,  this.identifier,  `")[`, overloadIndex, `]`);
    }

    final Variant opCall(Variant[] args = []) const
        in(caller !is null)
    {
        return caller(null, args);
    }

    final Variant opCall(void* context, Variant[] args = []) const
        in(context !is null)
        in(caller !is null)
    {
        return caller(context, args);
    }

    final R funCall(R = void, A...)(A args) const {
        Variant[A.length] variants;
        static foreach(i; 0 .. A.length) variants[i] = args[i];

        auto helper() {
            return opCall(variants[]);
        }

        static if(is(R == void))
            helper;
        else
            return helper.get!R;
    }

    final R methodCall(R = void, A...)(void* context, A args) const {
        Variant[A.length] variants;
        static foreach(i; 0 .. A.length) variants[i] = args[i];

        auto helper() {
            return opCall(context, variants[]);
        }

        static if(is(R == void))
            helper;
        else
            return helper.get!R;
    }
}


struct Type {
    string fullyQualifiedName;
    bool isArithmetic;
    bool isFloating;
    bool isIntegral;
    bool isScalar;
    bool isUnsigned;
    bool isStaticArray;
    bool isAssociativeArray;
    bool isAbstractClass;
    bool isFinalClass;
    bool isCopyable;
    bool isPOD;
    bool isZeroInit;
    bool hasCopyConstructor;
    bool hasMoveConstructor;
    bool hasPostblit;
    string[] aliasThis;
    size_t[] pointerBitmap;
    size_t classInstanceSize;
    size_t classInstanceAlignment;

    string toString() @safe pure scope const {
        return fullyQualifiedName.idup;
    }
}

auto type(T)() {
    Type ret;
    ret.fullyQualifiedName = __traits(fullyQualifiedName, T);

    enum boolTraits = [
        "isArithmetic", "isFloating", "isIntegral", "isScalar", "isUnsigned", "isStaticArray",
        "isAssociativeArray", "isAbstractClass", "isFinalClass", "isCopyable", "isPOD",
        "isZeroInit", "hasCopyConstructor",
        //"hasMoveConstructor", ???
        "hasPostblit",
    ];
    static foreach(trait; boolTraits) {
        mixin(`ret.`, trait, ` = __traits(`, trait, `, T);`);
    }

    ret.aliasThis = [ __traits(getAliasThis, T) ];
    static if(__traits(compiles, __traits(getPointerBitmap, T)))
        ret.pointerBitmap = __traits(getPointerBitmap, T);

    static if(is(T == class)) {
        ret.classInstanceSize = __traits(classInstanceSize, T);
        ret.classInstanceAlignment = __traits(classInstanceAlignment, T);
    }

    return ret;
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


class Variable: Member {
    Type type;

    override string aliasMixin() @safe pure scope const {
        return `__traits(getMember, ` ~ parent ~ `, "` ~ this.identifier ~ `")`;
    }
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


struct Location {
    string file;
    size_t line;
    size_t column;
}

class UDA {
    override string toString() @safe pure scope const {
        assert(0);
    }
}

class ValueUDA: UDA {
    Type type;
    string value;

    this(T)(T value) {
        import std.conv: text;
        this.type = .type!T;
        this.value = value.text;
    }

    override string toString() @safe pure scope const {
        import std.conv: text;
        return text(`ValueUDA(`, type, `, `, value, `)`);
    }

    override bool opEquals(Object other) @safe pure scope const {
        auto otherValue = cast(ValueUDA) other;
        if(!otherValue) return false;
        return type == otherValue.type && value == otherValue.value;
    }
}

class TypeUDA: UDA {
    Type type;

    static create(T)() {
        auto ret = new TypeUDA;
        ret.type = .type!T;
        return ret;
    }

    override string toString() @safe pure scope const {
        import std.conv: text;
        return text(`TypeUDA(`, type, `)`);
    }

    override bool opEquals(Object other) @safe pure scope const {
        auto otherType = cast(TypeUDA) other;
        if(!otherType) return false;
        return type == otherType.type;
    }
}

class SymbolUDA: UDA {
    string symbol;

    static create(alias S)() {
        import std.traits: fullyQualifiedName;
        auto ret = new SymbolUDA;
        ret.symbol = fullyQualifiedName!S;
        return ret;
    }

    override string toString() @safe pure scope const {
        import std.conv: text;
        return text(`SymbolUDA(`, symbol, `)`);
    }

    override bool opEquals(Object other) @safe pure scope const {
        auto otherSymbol = cast(SymbolUDA) other;
        if(!otherSymbol) return false;
        return symbol == otherSymbol.symbol;
    }
}


mixin template registerModule(string moduleName = __MODULE__) {

    immutable mirror.ctfe.reflection.Module gModuleInfo;

    shared static this() @safe nothrow {
        gModuleInfo = module_!(moduleName);
        allModuleInfos ~= gModuleInfo;
    }
}

// shared immutable seems silly but otherwise there's a copy per
// thread.
shared immutable(Module)[] allModuleInfos;


template Caller(alias F) {

    import std.variant: Variant;
    import std.typecons: Tuple;
    import std.traits: Parameters, ReturnType, fullyQualifiedName, Unqual;
    import std.conv: text;
    import std.string: replace;
    import std.functional: toDelegate;
    import std.meta: staticMap;

    Tuple!(staticMap!(Unqual, Parameters!F)) args;

    enum isFreeFunction = __traits(isModule, __traits(parent, F));
    static if(isFreeFunction)
        alias FuncPtr = typeof(&F);
    else
        alias FuncPtr = typeof(toDelegate(&F));

    Variant impl(void* context, Variant[] variantArgs) {

        FuncPtr fptr;

        static if(isFreeFunction)
            fptr = &F;
        else {
            fptr.funcptr = &F;
            fptr.ptr = context;
        }

        if(variantArgs.length != Parameters!F.length)
            throw new Exception(
                text("Cannot call `", fullyQualifiedName!F, "` with ",
                     variantArgs.length, " arguments. Expected: ", Parameters!F.length));

        static foreach(i; 0 .. args.length) {
            try
                args[i] = variantArgs[i].get!(Parameters!F[i]);
            catch(Exception e)
                throw new Exception(
                    text(
                        "Expected argument #", i, " of `", fullyQualifiedName!F,
                        "` to be `", fullyQualifiedName!(Parameters!F[i]),
                        "`, got: `", variantArgs[i], "`: `", variantArgs[i].type, "`",
                        "\nException: ", e.msg,
                        )
                    );
        }

        auto helper() {
            return fptr(args.expand);
        }
        static if(is(ReturnType!F == void)) {
            helper;
            return Variant();
        } else
            return Variant(helper);
    }
}
