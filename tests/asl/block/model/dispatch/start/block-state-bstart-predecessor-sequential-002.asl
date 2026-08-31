// PTO-TEST: {"id":"PTO-AVS-BSTART-PREDECESSOR-SEQUENTIAL-002","source":"asl/block/model/dispatch/start.asl","requirements":["PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001"],"kind":"state-transition","summary":"A following BSTART installs when the predecessor selects that exact sequential boundary.","pass_condition":"FALL, untaken conditional, and a taken target equal to the boundary all install the new BARG.","related_sources":["asl/block/model/commit/validation.asl","asl/block/model/lifecycle/begin.asl"]}
func main() => integer
begin
    let next_start = Zeros{64} + 0x00001001;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let fall = ExecuteCommandInstruction(Zeros{64} + 0x00001001, 32);
    let after_fall = ExecuteCommandInstruction(next_start, 32);
    assert fall == CommandExecution_Executed;
    assert after_fall == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x104;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    var conditional = Zeros{64} + 0x00000021;
    conditional[31:7] = Zeros{25} + 0x20;
    let conditional_start = ExecuteCommandInstruction(conditional, 32);
    let after_untaken = ExecuteCommandInstruction(next_start, 32);
    assert conditional_start == CommandExecution_Executed;
    assert after_untaken == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x204;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x208;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    var same_target = Zeros{64} + 0x00000011;
    same_target[31:7] = Zeros{25} + 2;
    let same_start = ExecuteCommandInstruction(same_target, 32);
    let after_same = ExecuteCommandInstruction(next_start, 32);
    assert same_start == CommandExecution_Executed;
    assert after_same == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x304;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x308;
    return 0;
end;
