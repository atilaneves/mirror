module modules.issues;


struct Issue1 {
    static struct String { string value; }
    size_t length(String str) { return str.value.length; }
}


struct CtorProtectionsStruct {
    // the public one must be first so that it's the default symbol if anyone
    // tries to reflect on "__ctor"
    public this(double d) {}
    private this(int i, string s) {}
    package this(string s, int i) {}
}
