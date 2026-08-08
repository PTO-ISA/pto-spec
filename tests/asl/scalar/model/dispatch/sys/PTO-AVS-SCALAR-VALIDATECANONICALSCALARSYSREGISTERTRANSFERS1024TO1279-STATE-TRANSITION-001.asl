// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSREGISTERTRANSFERS1024TO1279-STATE-TRANSITION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSRegisterTransfers1024To1279","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers1024To1279 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers1024To1279();
    return 0;
end;
