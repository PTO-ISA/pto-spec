// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-MAINT-SELECTOR-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"boundary","summary":"Covers Canonical Scalar SYS Maintenance Selector Totality.","pass_condition":"ValidateCanonicalScalarSYSMaintenanceSelectorTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSMaintenanceSelectorTotality();
    return 0;
end;
