// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-TRAP-RECOVERY-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"fault","summary":"Covers Canonical Scalar SYS Trap And Recovery Totality.","pass_condition":"ValidateCanonicalScalarSYSTrapAndRecoveryTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSTrapAndRecoveryTotality();
    return 0;
end;
