// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-PLACE-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"B.FPATR rejects inactive, body-phase, and post-binding placement before latching fields","pass_condition":"every invalid placement raises Fault_BundleControl at the current TPC and preserves the absent descriptor and existing operand binding","related_sources":["asl/block/model/dispatch/commands.asl"]}
func PrepareMatrixHeader(pc: Word)
begin
    ResetProfileState();
    WriteTPC(pc);
    _BundleActive = TRUE;
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMatrix;
end;

func AssertBFPATRRejectedWithoutState()
begin
    let status = ExecuteCommandInstruction(Zeros{64} + 0x00002023, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleFixedPointAttributes.valid;
end;

func AssertBFPATRRejectedAfterScalarBinding()
begin
    let binding = ExecuteCommandInstruction(Zeros{64} + 0x00000013, 32);
    assert binding == CommandExecution_Executed;
    assert _BundleScalarBindings[[0]].valid;
    let after_binding = ReadTPC();

    AssertBFPATRRejectedWithoutState();
    assert ReadTPC() == after_binding;
    assert _BundleScalarBindings[[0]].valid;
end;

func AssertBFPATRRejectedAfterTileBinding()
begin
    var source = Zeros{64} + 0x00005013;
    source[18:15] = Zeros{4};
    source[11:9] = '111';
    source[19] = '1';
    let binding = ExecuteCommandInstruction(source, 32);
    assert binding == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].valid;
    let after_binding = ReadTPC();

    AssertBFPATRRejectedWithoutState();
    assert ReadTPC() == after_binding;
    assert _BundleTileBindings[[0]].valid;
end;

func AssertBFPATRRejectedAfterSharedBinding()
begin
    var source = Zeros{64} + 0x00001013;
    source[25:20] = Zeros{6} + 7;
    source[18:15] = Zeros{4};
    source[11:9] = '111';
    let binding = ExecuteCommandInstruction(source, 32);
    assert binding == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    let after_binding = ReadTPC();

    AssertBFPATRRejectedWithoutState();
    assert ReadTPC() == after_binding;
    assert _BundleSharedBindings[[0]].valid;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    AssertBFPATRRejectedWithoutState();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x300;

    PrepareMatrixHeader(Zeros{PTO_XLEN} + 0x340);
    _BundleBodyActive = TRUE;
    AssertBFPATRRejectedWithoutState();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x340;

    PrepareMatrixHeader(Zeros{PTO_XLEN} + 0x380);
    AssertBFPATRRejectedAfterScalarBinding();

    PrepareMatrixHeader(Zeros{PTO_XLEN} + 0x3c0);
    AssertBFPATRRejectedAfterTileBinding();

    PrepareMatrixHeader(Zeros{PTO_XLEN} + 0x400);
    AssertBFPATRRejectedAfterSharedBinding();
    return 0;
end;
