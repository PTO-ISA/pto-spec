// PTO-TEST: {"id":"PTO-AVS-BLOCK-TUNPACK-PARTIAL-SELECTED-BYTE-R4-001","source":"asl/block/model/dispatch/cell-rearrangement-schema.asl","requirements":["PTO-TUNPACK-CONTRACT-001"],"kind":"fault","summary":"Decoded TUNPACK rejects an offset outside a one-byte logical tail before destination publication.","pass_condition":"U8 [2,1] with offset 1/count 1 faults with Fault_TileLegality, leaves the fresh destination unallocated, and does not change numeric status.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/execution/rearrangement.asl"]}
pure func PartialByteTUNPACKStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = Zeros{5} + 24;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func PartialByteLayoutAttribute() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert source;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x22);
    let started = ExecuteCommandInstruction(PartialByteTUNPACKStart(), 32);
    let attributed = ExecuteCommandInstruction(
        PartialByteLayoutAttribute(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000101);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
