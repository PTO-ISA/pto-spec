// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARAMOTOTALITY-BOUNDARY-001","source":"asl/scalar/model/dispatch/amo.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for ValidateCanonicalScalarAMOTotality","pass_condition":"ValidateCanonicalScalarAMOTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOTotality();
    return 0;
end;
