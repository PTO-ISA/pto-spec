func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSEffects();
    TestScalarSystemDispatchEffects();
    TestScalarSystem();
    TestServiceRequestControl();
    return 0;
end;
