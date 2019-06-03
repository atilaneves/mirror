import reggae;
enum commonFlags = "-w -g -debug";
alias ut = dubTestTarget!(CompilerFlags(commonFlags));
mixin build!(ut);
