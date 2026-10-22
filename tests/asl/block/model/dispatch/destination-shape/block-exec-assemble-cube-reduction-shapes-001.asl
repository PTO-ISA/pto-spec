// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-REDUCTION-SHAPES-001","source":"asl/block/model/dispatch/destination-shape.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TROWSUM-CONTRACT-001","PTO-TCOLSUM-CONTRACT-001"],"kind":"execution","summary":"Assembled CUBE row and column reductions retain distinct operation-derived output shapes","pass_condition":"row reduction publishes valid 2x1 and column reduction publishes valid 1x2 from 2x2 sources while each writer records its independent shape inside a 512-byte 16x8 parent","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/reduction.asl"]}
pure func AssembledCubeReductionStart(column_reduction: boolean)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = if column_reduction then '10000' else '00000';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func AssembledCubeM16Attribute() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    return instruction;
end;

func RunAssembledCubeReduction(column_reduction: boolean)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTileForMaskWithPhysical(
        1, 128, 16, 2, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M16, '0001');
    assert source_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(
        AssembledCubeReductionStart(column_reduction), 32);
    let attributed = ExecuteCommandInstruction(AssembledCubeM16Attribute(), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', TRUE, FALSE, 1, 0, TRUE);
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = TRUE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    _BundleTileBindings[[0]].destination_assemble.size_code = 1;
    _BundleTileBindings[[0]].destination_assemble.offset = Zeros{PTO_XLEN};

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let slot_value = BundleLocalGenerationSlotForDestination(0);
    assert slot_value < 64;
    let slot = slot_value as integer {0..63};
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, 0, 1);
    assert ready && _LocalGenerations[[slot]].published;
    let destination = _LocalGenerations[[slot]].working_destination;
    let writer = _LocalGenerations[[slot]].writers[[0]];
    assert _LocalGenerations[[slot]].writer_count == 1 && writer.valid &&
           writer.offset_cells == 0 && writer.cell_count == 1 &&
           writer.physical_rows == 16 && writer.physical_columns == 2 &&
           writer.valid_rows == (if column_reduction then 1 else 2) &&
           writer.valid_columns == (if column_reduction then 2 else 1);
    assert _LocalGenerations[[slot]].published &&
           _Tiles[[destination]].capacity_bytes == 512 &&
           _Tiles[[destination]].rows == 16 &&
           _Tiles[[destination]].columns == 8 &&
           _Tiles[[destination]].valid_rows == (if column_reduction then 1 else 2) &&
           _Tiles[[destination]].valid_columns == (if column_reduction then 2 else 1);
    if column_reduction then
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 4 &&
               ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 6;
    else
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 3 &&
               ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 7;
    end;
end;

func main() => integer
begin
    RunAssembledCubeReduction(FALSE);
    RunAssembledCubeReduction(TRUE);
    return 0;
end;
