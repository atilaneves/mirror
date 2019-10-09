module ut;


public import unit_threaded;


// Passing two AliasSeqs causes them to collapse into their concatenated contents
void shouldEqual(A...)() {

    import std.conv: text;

    static assert(A.length % 2 == 0,
                  text("\n\n",
                       "Can only compare even number of template arguments, not sequence of length ",
                       A.length, ":\n\n",
                       A.stringof,
                       "\n\n",
                  )
    );

    static foreach(i; 0 .. A.length / 2) {{
        enum j = i + A.length / 2;
        static assert(__traits(isSame, A[i], A[j]),
                      text("\n\n",
                           "    Expected: ", A[A.length / 2 .. $].stringof,
                           "\n\n",
                           "    Got:      ", A[0 .. A.length / 2].stringof,
                           "\n\n",
                      )
        );
    }}
}
