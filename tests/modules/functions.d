module modules.functions;


int add1(int i, int j) {
    return i + j + 1;
}


double add1(double d0, double d1) {
    return d0 + d1 + 1;
}


double withDefault(double d0, double d1 = 33.3) {
    return d0 + d1;
}


void storageClasses(
    int normal,
    return scope int* returnScope,
    out int out_,
    ref int ref_,
    lazy int lazy_,
    )
{

}
