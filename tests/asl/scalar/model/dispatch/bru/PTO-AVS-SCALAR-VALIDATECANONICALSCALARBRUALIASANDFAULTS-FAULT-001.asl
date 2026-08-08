// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARBRUALIASANDFAULTS-FAULT-001","source":"asl/scalar/model/dispatch/bru.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for ValidateCanonicalScalarBRUAliasAndFaults","pass_condition":"ValidateCanonicalScalarBRUAliasAndFaults completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarBRUAliasAndFaults();
    return 0;
end;
