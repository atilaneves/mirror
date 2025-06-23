module prod.maths;


import mirror;


mixin registerModule!();


long twice(long i) @safe @nogc pure nothrow {
    return i * 2;
}

long mul(long i, long j) @safe @nogc pure nothrow {
    return i * j;
}
