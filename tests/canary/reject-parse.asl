// Known-bad ASL1: the parameter list is never closed. Parsing must fail before
// type-checking begins.
func Canary_ParseError( => integer
begin
    return 0;
end;
