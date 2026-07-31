func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAGUEffects();
    TestScalarAGUDispatchEffects();
    return 0;
end;
