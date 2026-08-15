// PTO-TEST: {"id":"PTO-AVS-SCALAR-FP-FLAGS-001","source":"asl/scalar/model/dispatch/fsu.asl","requirements":[],"kind":"state-transition","summary":"Floating-point status flags accumulate every incoming exception bit without clearing sticky state.","pass_condition":"ValidateScalarFPFlagHelpers completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ValidateScalarFPFlagHelpers();
    return 0;
end;
