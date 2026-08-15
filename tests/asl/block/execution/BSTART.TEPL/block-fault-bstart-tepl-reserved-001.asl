// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TEPL-RESERVED-001","source":"asl/block/execution/BSTART.TEPL.asl","requirements":["PTO-INST-BLOCK-BSTART-TEPL"],"kind":"fault","summary":"TEPL selector holes and reserved DataType codes reject before block effects.","pass_condition":"An unassigned Mode:Function selector and reserved DataType boundaries reject without installing a block or changing BPC.","related_sources":["asl/block/model/dispatch/descriptor-legality.asl","asl/arch/data-types/tile-data-types.asl"]}
func AssertTEPLRejected(instruction: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    WriteBPC(Zeros{PTO_XLEN} + 0x380);
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault != Fault_None;
    assert !_BundleActive;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x380;
end;

func main() => integer
begin
    // Mode 0, Function 5 is an unassigned selector hole.
    AssertTEPLRejected(Zeros{64} + 0x00519181);
    // DataType codes 15 and 31 are reserved at carrier level.
    AssertTEPLRejected(Zeros{64} + 0x78019181);
    AssertTEPLRejected(Zeros{64} + 0xf8019181);
    return 0;
end;
