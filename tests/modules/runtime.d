module modules.runtime;


import mirror;


mixin registerModule!();


int twice(int i) @safe @nogc pure nothrow {
    return i * 2;
}

int mul(int i, int j) @safe @nogc pure nothrow {
    return i * j;
}
