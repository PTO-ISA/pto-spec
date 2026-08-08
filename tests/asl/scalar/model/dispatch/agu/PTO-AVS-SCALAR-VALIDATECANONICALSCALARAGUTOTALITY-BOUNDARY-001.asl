// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARAGUTOTALITY-BOUNDARY-001","source":"asl/scalar/model/dispatch/agu.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for ValidateCanonicalScalarAGUTotality","pass_condition":"ValidateCanonicalScalarAGUTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAGUTotality();
    return 0;
end;
