// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-TMATMUL-AUX-WRITER-SHAPES-001","source":"asl/block/model/dispatch/cube-destination.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"TMATMUL Local writers carry independent primary, RowMax, and GroupMax shapes","pass_condition":"the 1x8 primary and both 1x1 auxiliaries have distinct valid writer widths and exact ranges while all retained parents remain capacity-backed 16x8 descriptors with correct matrix results","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/postprocess.asl"]}
pure func AssembledMatrixStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func AssembledMatrixFP16Value(value: integer {1..8}) => Word
begin
    case value of
        when 1 => return Zeros{PTO_XLEN} + 0x3c00;
        when 2 => return Zeros{PTO_XLEN} + 0x4000;
        when 3 => return Zeros{PTO_XLEN} + 0x4200;
        when 4 => return Zeros{PTO_XLEN} + 0x4400;
        when 5 => return Zeros{PTO_XLEN} + 0x4500;
        when 6 => return Zeros{PTO_XLEN} + 0x4600;
        when 7 => return Zeros{PTO_XLEN} + 0x4700;
        when 8 => return Zeros{PTO_XLEN} + 0x4800;
    end;
end;

func SetMatrixWriter(binding: integer {0..2}, writer_size: integer {1,3})
begin
    _BundleTileBindings[[binding]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.init = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.last = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.size_code =
        writer_size as integer {1..12};
    _BundleTileBindings[[binding]].destination_assemble.offset =
        Zeros{PTO_XLEN};
end;

func AssertMatrixWriter(binding: integer {0..2},
                        writer_columns: integer {1,2,8},
                        valid_columns: integer {1,8},
                        writer_size: integer {1,3})
begin
    let destination = _BundleTileBindings[[binding]].destination;
    let slot_value = BundleLocalGenerationSlotForDestination(destination);
    assert slot_value < 64;
    let slot = slot_value as integer {0..63};
    assert _LocalGenerations[[slot]].writer_count == 1;
    let writer = _LocalGenerations[[slot]].writers[[0]];
    assert writer.valid;
    assert writer.offset_cells == 0;
    assert writer.cell_count == (if writer_size == 3 then 4 else 1);
    assert writer.physical_rows == 16;
    assert writer.physical_columns == writer_columns;
    assert writer.valid_rows == _Tiles[[destination]].valid_rows;
    assert writer.valid_columns == _Tiles[[destination]].valid_columns;
    if binding == 0 then
        assert binding == 0 && writer.valid_columns == 8;
    elsif binding == 1 then
        assert binding == 1 && writer.valid_columns == 1;
    else
        assert binding == 2 && writer.valid_columns == 1;
    end;
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, 0,
        writer.cell_count as integer {1..2048});
    assert ready && _LocalGenerations[[slot]].published;
    assert _Tiles[[destination]].capacity_bytes == 512 &&
           _Tiles[[destination]].rows == 16 &&
           _Tiles[[destination]].columns == 8 &&
           _Tiles[[destination]].valid_rows == 1 &&
           _Tiles[[destination]].valid_columns == valid_columns;
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let b_ready = ConfigureCubeTileForMask(5, 128, 1, 8,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let row_max_in_ready = ConfigureCubeTileForMask(6, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert a_ready && b_ready && row_max_in_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(5, 0, column,
            AssembledMatrixFP16Value((column + 1) as integer {1..8}));
    end;
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);

    let started = ExecuteCommandInstruction(AssembledMatrixStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', TRUE, TRUE, 4, 5, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 3, '1111', TRUE, FALSE, 6, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 3, '1111', FALSE, FALSE, 0, 0, TRUE);
    SetMatrixWriter(0, 3);
    SetMatrixWriter(1, 1);
    SetMatrixWriter(2, 1);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let primary = _BundleTileBindings[[0]].destination;
    let row_max = _BundleTileBindings[[1]].destination;
    let group_max = _BundleTileBindings[[2]].destination;
    AssertMatrixWriter(0, 8, 8, 3);
    assert _Tiles[[primary]].valid_rows == 1 &&
           _Tiles[[primary]].valid_columns == 8;
    AssertMatrixWriter(1, 2, 1, 1);
    assert _Tiles[[row_max]].valid_rows == 1 &&
           _Tiles[[row_max]].valid_columns == 1;
    AssertMatrixWriter(2, 2, 1, 1);
    assert _Tiles[[group_max]].valid_rows == 1 &&
           _Tiles[[group_max]].valid_columns == 1;
    assert ReadTileElement(primary, 0, 7) ==
               Zeros{PTO_XLEN} + 0x41800000 &&
           ReadTileElement(row_max, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41800000 &&
           ReadTileElement(group_max, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41800000;

    // With RowMax only, the absent GroupMax output falls back to the primary
    // Tile index. It must not overwrite that writer or the RowMax result.
    ResetProfileState();
    let row_a_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let row_b_ready = ConfigureCubeTileForMask(5, 128, 1, 8,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let row_input_ready = ConfigureCubeTileForMask(6, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert row_a_ready && row_b_ready && row_input_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(5, 0, column,
            AssembledMatrixFP16Value((column + 1) as integer {1..8}));
    end;
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
    let row_started = ExecuteCommandInstruction(AssembledMatrixStart(), 32);
    assert row_started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0000', TRUE, FALSE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, TRUE, 4, 5, FALSE);
    AddBundleTileBinding(TRUE, 1, 3, '1111', TRUE, FALSE, 6, 0, TRUE);
    SetMatrixWriter(0, 3);
    SetMatrixWriter(1, 1);
    let row_completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert row_completed;
    let row_primary = _BundleTileBindings[[0]].destination;
    let row_output = _BundleTileBindings[[1]].destination;
    AssertMatrixWriter(0, 8, 8, 3);
    AssertMatrixWriter(1, 2, 1, 1);
    assert TileElementDefined(row_primary, 0, 7) &&
           TileElementDefined(row_output, 0, 0) &&
           ReadTileElement(row_primary, 0, 7) ==
               Zeros{PTO_XLEN} + 0x41800000 &&
           ReadTileElement(row_output, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41800000;

    return 0;
end;
