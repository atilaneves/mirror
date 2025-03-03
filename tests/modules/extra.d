module modules.extra;

@safe pure unittest {}
@safe pure unittest { throw new Exception("oh noes"); }

struct Struct {
    @safe pure unittest { throw new Exception("oh noes from struct"); }
}
