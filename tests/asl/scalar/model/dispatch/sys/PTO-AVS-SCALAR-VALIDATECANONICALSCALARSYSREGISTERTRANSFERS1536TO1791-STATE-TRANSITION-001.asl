// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSREGISTERTRANSFERS1536TO1791-STATE-TRANSITION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSRegisterTransfers1536To1791","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers1536To1791 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers1536To1791();
    return 0;
end;
