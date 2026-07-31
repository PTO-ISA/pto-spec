func main() => integer
begin
    ResetProfileState();
    TestTSOConcurrency();
    TestConcreteProfile();
    return 0;
end;
