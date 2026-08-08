// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSREGISTERTRANSFERS1792TO1936-STATE-TRANSITION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSRegisterTransfers1792To1936","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers1792To1936 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers1792To1936();
    return 0;
end;
