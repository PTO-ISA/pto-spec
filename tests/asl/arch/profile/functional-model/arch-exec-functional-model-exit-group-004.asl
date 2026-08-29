// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-MODEL-EXIT-GROUP-004","source":"asl/arch/profile/functional-model.asl","requirements":["PTO-REQ-FUNCTIONAL-EXIT-GROUP-001"],"kind":"execution","summary":"The initialized functional profile maps the exact ACRC SYS exit_group tuple to one immutable host request.","pass_condition":"ACRC request 1 with a7=94 captures a0, a0 as the response GPR, and the next instruction PC without entering portable service-request trap state.","related_sources":["asl/scalar/model/sys/semantics.asl","asl/scalar/sys/ACRC.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    let a0_initialized = InitializeFunctionalModelGPR(
        2, Zeros{PTO_XLEN} + 7);
    let a7_initialized = InitializeFunctionalModelGPR(
        9, Zeros{PTO_XLEN} + 94);
    assert a0_initialized && a7_initialized;

    ArchitectureCloseRequest('0001');

    assert _LastFault == Fault_None;
    assert _SystemBlockTerminalPending;
    assert FunctionalModelHostRequestPending();
    assert FunctionalModelHostRequestOriginPE() == 0;
    assert FunctionalModelHostRequestType() == Zeros{16} + 94;
    assert FunctionalModelHostRequestArgument0() == Zeros{PTO_XLEN} + 7;
    let token = FunctionalModelHostRequestToken();
    let completion = CompleteFunctionalModelHostRequest(
        token, Zeros{PTO_XLEN} + 7);
    assert completion == PTOFunctionalHostCompletion_Accepted;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 7;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    return 0;
end;
