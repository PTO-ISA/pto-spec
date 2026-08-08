// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSREGISTERTRANSFERS0TO255-STATE-TRANSITION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSRegisterTransfers0To255","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers0To255 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers0To255();
    return 0;
end;
