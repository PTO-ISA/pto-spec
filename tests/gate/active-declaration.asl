// Regression fixture: the plain declaration form the previous keyword scan did
// detect. The gate must keep detecting it.
func Gate_PlainDeclaration() => integer
begin
    return 0;
end;
