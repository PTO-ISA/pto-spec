// PTO-TEST: {"id":"PTO-AVS-SCALAR-FP-ROUND-001","source":"asl/scalar/model/dispatch/fsu.asl","requirements":[],"kind":"boundary","summary":"Active and fixed scalar floating-point rounding selectors map to their assigned architectural modes.","pass_condition":"ValidateScalarFPRoundingHelpers completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ValidateScalarFPRoundingHelpers();
    return 0;
end;
