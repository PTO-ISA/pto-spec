// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-SYSREG-RESET-ACCESS-001","source":"asl/arch/data-types/system-registers.asl","requirements":[],"kind":"state-transition","summary":"Covers System Register Reset And Access.","pass_condition":"ValidateSystemRegisterResetAndAccess completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateSystemRegisterResetAndAccess();
    return 0;
end;
