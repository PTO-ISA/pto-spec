// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARALUTOTALITY-BOUNDARY-001","source":"asl/scalar/model/dispatch/alu.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for ValidateCanonicalScalarALUTotality","pass_condition":"ValidateCanonicalScalarALUTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarALUTotality();
    return 0;
end;
