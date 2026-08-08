// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSREGISTERTRANSFERS256TO511-STATE-TRANSITION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSRegisterTransfers256To511","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers256To511 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers256To511();
    return 0;
end;
