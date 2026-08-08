// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSMAINTENANCELEGALITYTOTALITY-BOUNDARY-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSMaintenanceLegalityTotality","pass_condition":"ValidateCanonicalScalarSYSMaintenanceLegalityTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSMaintenanceLegalityTotality();
    return 0;
end;
