// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-HOST-PENDING-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"],"kind":"state-transition","summary":"Repeated step while a host request is pending returns the same token without architectural effects.","pass_condition":"Two pending ExecuteOnePTOStep calls return HostRequest with one token while TPC, GPR, and pending state remain unchanged.","related_sources":["asl/arch/programming-model/scalar-registers.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    let gpr_initialized = InitializeFunctionalModelGPR(
        3,
        Zeros{PTO_XLEN} + 0x33);
    assert gpr_initialized;
    let request_started = BeginFunctionalModelHostRequest(
        Zeros{16} + 94,
        Zeros{PTO_XLEN} + 7,
        3,
        Zeros{PTO_XLEN} + 0x104);
    assert request_started;
    let token = FunctionalModelHostRequestToken();

    let first = ExecuteOnePTOStep();
    let second = ExecuteOnePTOStep();

    assert first.status == PTOFunctionalStep_HostRequest;
    assert second.status == PTOFunctionalStep_HostRequest;
    assert first.request_token == token;
    assert second.request_token == token;
    assert first.pre_tpc == Zeros{PTO_XLEN} + 0x100;
    assert first.post_tpc == first.pre_tpc;
    assert second.pre_tpc == first.pre_tpc;
    assert second.post_tpc == first.pre_tpc;
    assert first.origin_pe == 0 && second.origin_pe == 0;
    assert FunctionalModelHostRequestPending();
    assert FunctionalModelHostRequestToken() == token;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x33;
    return 0;
end;
