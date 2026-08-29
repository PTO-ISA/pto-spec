// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-MODEL-TOKEN-RESET-STALE-003","source":"asl/arch/profile/functional-model.asl","requirements":["PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"],"kind":"fault","summary":"Architecture reset does not make a completed host token valid for a later request in the same model instance.","pass_condition":"A request after reinitialization receives a new token and completion with the old token is rejected without changing its pending state, result GPR, or TPC.","related_sources":["asl/arch/state/functional-model.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    let first_started = BeginFunctionalModelHostRequest(
        Zeros{16} + 1,
        Zeros{PTO_XLEN} + 7,
        3,
        Zeros{PTO_XLEN} + 0x104);
    assert first_started;
    let stale_token = FunctionalModelHostRequestToken();
    let first_completion = CompleteFunctionalModelHostRequest(
        stale_token,
        Zeros{PTO_XLEN} + 0x11);
    assert first_completion == PTOFunctionalHostCompletion_Accepted;

    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x200);
    let second_started = BeginFunctionalModelHostRequest(
        Zeros{16} + 2,
        Zeros{PTO_XLEN} + 8,
        3,
        Zeros{PTO_XLEN} + 0x204);
    assert second_started;
    let current_token = FunctionalModelHostRequestToken();
    assert current_token == stale_token + 1;

    let stale_completion = CompleteFunctionalModelHostRequest(
        stale_token,
        Zeros{PTO_XLEN} + 0x99);

    assert stale_completion == PTOFunctionalHostCompletion_Rejected;
    assert FunctionalModelHostRequestPending();
    assert FunctionalModelHostRequestToken() == current_token;
    assert ReadPEGPR(0, 3) == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    return 0;
end;
