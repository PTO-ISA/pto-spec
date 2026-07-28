// Known-bad ASL1: the returned expression is a boolean, not the declared
// integer. Strict type-checking must reject this file.
func Canary_TypeError() => integer
begin
    return TRUE;
end;
