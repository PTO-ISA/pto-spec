// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-VALIDATESYSTEMREGISTERRESETANDACCESS-STATE-TRANSITION-001","source":"asl/arch/data-types/system-registers.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for ValidateSystemRegisterResetAndAccess","pass_condition":"ValidateSystemRegisterResetAndAccess completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateSystemRegisterResetAndAccess();
    return 0;
end;
