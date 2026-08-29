// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-MODEL-TOKEN-EXHAUSTION-002","source":"asl/arch/profile/functional-model.asl","requirements":["PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"],"kind":"boundary","summary":"A functional-model instance refuses a new host request when its token space is exhausted.","pass_condition":"BeginFunctionalModelHostRequest returns false at the maximum next-token value without creating or mutating pending request state.","related_sources":["asl/arch/state/functional-model.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    let sequence = _FunctionalProfileSequence;
    _FunctionalHostRequestNextToken = Ones{PTO_XLEN};

    let request_started = BeginFunctionalModelHostRequest(
        Zeros{16} + 94,
        Zeros{PTO_XLEN} + 7,
        3,
        Zeros{PTO_XLEN} + 0x104);

    assert !request_started;
    assert !FunctionalModelHostRequestPending();
    assert FunctionalModelHostRequestToken() == Zeros{PTO_XLEN};
    assert _FunctionalHostRequestNextToken == Ones{PTO_XLEN};
    assert _FunctionalProfileSequence == sequence;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadPEGPR(0, 3) == Zeros{PTO_XLEN};
    return 0;
end;
