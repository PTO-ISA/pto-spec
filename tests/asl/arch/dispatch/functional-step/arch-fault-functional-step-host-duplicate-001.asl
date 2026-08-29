// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-HOST-DUPLICATE-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"],"kind":"fault","summary":"A duplicate host completion is rejected after the first completion commits exactly once.","pass_condition":"The first matching completion writes its result and resume TPC; repeating the same token returns Rejected and preserves committed state.","related_sources":["asl/arch/programming-model/scalar-registers.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x300);
    let gpr_initialized = InitializeFunctionalModelGPR(
        5,
        Zeros{PTO_XLEN} + 0x55);
    assert gpr_initialized;
    let request_started = BeginFunctionalModelHostRequest(
        Zeros{16} + 94,
        Zeros{PTO_XLEN} + 9,
        5,
        Zeros{PTO_XLEN} + 0x304);
    assert request_started;
    let token = FunctionalModelHostRequestToken();

    let first = CompleteFunctionalModelHostRequest(
        token,
        Zeros{PTO_XLEN} + 0xaa);
    assert first == PTOFunctionalHostCompletion_Accepted;
    assert !FunctionalModelHostRequestPending();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0xaa;

    let duplicate = CompleteFunctionalModelHostRequest(
        token,
        Zeros{PTO_XLEN} + 0xbb);
    assert duplicate == PTOFunctionalHostCompletion_Rejected;
    assert !FunctionalModelHostRequestPending();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0xaa;
    return 0;
end;
