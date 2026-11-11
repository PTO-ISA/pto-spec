// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-CATALOG-WITNESSES-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001"],"kind":"decode-positive","summary":"Every projected scoped Scalar catalog entry decodes through its exact 64-bit witness and retains its base form, handler, scope, length, and operand legality.","pass_condition":"ValidateScopedScalarCarrierPriorityDecode completes all 705 generated witnesses and base-form checks without assertion failure.","related_sources":["asl/scalar/model/dispatch/top-level.asl"]}
func main() => integer
begin
    ResetProfileState();
    ValidateScopedScalarCarrierPriorityDecode();
    return 0;
end;
