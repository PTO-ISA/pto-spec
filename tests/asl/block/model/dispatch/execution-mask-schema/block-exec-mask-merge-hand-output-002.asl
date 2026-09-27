// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-MERGE-HAND-OUTPUT-002","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TADD-CONTRACT-001","PTO-B-IOR-BINDING-001"],"kind":"execution","summary":"ExecutionMask MERGE reads the prior published destination for the encoded hand before allocating the new destination.","pass_condition":"A decoded TADD preserves an inactive value from physical Tile 12 while the encoded destination hand and free allocation candidate are zero; a prior hand output with the wrong logical shape rejects before allocation.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/execution-mask-state.asl"]}
pure func MergeHandTADDStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2};
    instruction[24:20] = Zeros{5};
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func MergeHandAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    return instruction;
end;

pure func MergeHandIOR(source0: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[26] = '1';
    return instruction;
end;

pure func MergeHandIOT(left: bits(6), right: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = right;
    instruction[25:20] = left;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

func PrepareMergeHandBundle(wrong_base_shape: boolean)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        11, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        12, 128, 1, if wrong_base_shape then 1 else 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && base_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    // Relative selector zero is hand zero, distance zero.  The prior output
    // is deliberately a different physical Tile from the raw hand encoding.
    InstallRelativeTileFixture(0, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 90);
    if !wrong_base_shape then
        WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 91);
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    MarkTileValidRegionDefined(12);

    // Only logical coordinate (0,0) is active in CUBE_M16 U32 mapping.
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(MergeHandTADDStart(), 32);
    let attributed = ExecuteCommandInstruction(MergeHandAttributes(), 32);
    let masked = ExecuteCommandInstruction(
        MergeHandIOR(Zeros{5} + 2), 32);
    let bound = ExecuteCommandInstruction(
        MergeHandIOT(Zeros{6} + 10, Zeros{6} + 11), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    assert masked == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    assert !_Tiles[[0]].allocated;
    assert _BundleTileBindings[[0]].destination == 0;
    assert UInt(_BundleTileBindings[[0]].destination_hand) == 0;
end;

func main() => integer
begin
    PrepareMergeHandBundle(FALSE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination == 0;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 91;

    PrepareMergeHandBundle(TRUE);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
