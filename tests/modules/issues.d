module modules.issues;


struct Issue1 {
    static struct String { string value; }
    size_t length(String str) { return str.value.length; }
}
