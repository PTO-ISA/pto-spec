// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPACK-PARTIAL-SELECTED-BYTE-R4-001","source":"asl/block/model/dispatch/cell-rearrangement-schema.asl","requirements":["PTO-TPACK-CONTRACT-001"],"kind":"fault","summary":"Decoded TPACK rejects a selected prefix wider than one source's logical raw-word tail before publication.","pass_condition":"U8 [2,1] sources with src0_bytes=2 and src1_bytes=1 fault with Fault_TileLegality, leave the fresh destination unallocated, and do not change numeric status.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/execution/rearrangement.asl"]}
pure func PartialByteTPACKStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = Zeros{5} + 23;
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
    let source0 = ConfigureCubeTile(1, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let source1 = ConfigureCubeTile(2, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert source0 && source1;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x12);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x21);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0x22);
    let started = ExecuteCommandInstruction(PartialByteTPACKStart(), 32);
    let attributed = ExecuteCommandInstruction(
        PartialByteLayoutAttribute(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000102);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
