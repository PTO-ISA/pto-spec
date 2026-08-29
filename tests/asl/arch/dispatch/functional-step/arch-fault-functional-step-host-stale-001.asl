// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-HOST-STALE-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"],"kind":"fault","summary":"A stale host completion token is rejected without completing or mutating the pending request.","pass_condition":"Completion with token+1 returns Rejected and preserves pending token, TPC, and result GPR.","related_sources":["asl/arch/programming-model/scalar-registers.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x200);
    let gpr_initialized = InitializeFunctionalModelGPR(
        4,
        Zeros{PTO_XLEN} + 0x44);
    assert gpr_initialized;
    let request_started = BeginFunctionalModelHostRequest(
        Zeros{16} + 94,
        Zeros{PTO_XLEN} + 8,
        4,
        Zeros{PTO_XLEN} + 0x204);
    assert request_started;
    let token = FunctionalModelHostRequestToken();

    let completion = CompleteFunctionalModelHostRequest(
        token + 1,
        Zeros{PTO_XLEN} + 0x99);

    assert completion == PTOFunctionalHostCompletion_Rejected;
    assert FunctionalModelHostRequestPending();
    assert FunctionalModelHostRequestToken() == token;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x44;
    return 0;
end;
