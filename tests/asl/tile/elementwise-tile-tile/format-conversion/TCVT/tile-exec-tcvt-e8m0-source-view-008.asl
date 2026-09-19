// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-E8M0-SOURCE-VIEW-008","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-TCVT-E8M0-PROFILE-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TCVT bundles interpret U8-backed RowMajor and CUBE carriers as E8M0 without retagging the source.","pass_condition":"RowMajor, CUBE_M16, and a finalized CUBE_M32 parent convert E8M0 codes to independent FP32, BF16, and FP16 raw-bit goldens; 0xFF produces each target canonical quiet NaN without NV, and every U8 source descriptor remains unchanged.","related_sources":["asl/arch/data-types/formats/e8m0.asl","asl/arch/profile/tcvt-conversion.asl","asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/operands/local-generation-cube.asl"]}
pure func TCVTE8M0SourceStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x09b19181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_E8M0);
    return instruction;
end;

func AssertE8M0SourceUnchanged(before: TileInfo)
begin
    assert _Tiles[[1]].allocated == before.allocated;
    assert _Tiles[[1]].storage_kind == before.storage_kind;
    assert _Tiles[[1]].contents_defined == before.contents_defined;
    assert _Tiles[[1]].defined_elements == before.defined_elements;
    assert _Tiles[[1]].defined_valid_elements == before.defined_valid_elements;
    assert _Tiles[[1]].packed_defined_elements ==
        before.packed_defined_elements;
    assert _Tiles[[1]].capacity_bytes == before.capacity_bytes;
    assert _Tiles[[1]].rows == before.rows;
    assert _Tiles[[1]].columns == before.columns;
    assert _Tiles[[1]].valid_rows == before.valid_rows;
    assert _Tiles[[1]].valid_columns == before.valid_columns;
    assert _Tiles[[1]].data_type == before.data_type;
    assert _Tiles[[1]].predicate_basis_type == before.predicate_basis_type;
    assert _Tiles[[1]].layout == before.layout;
    assert _Tiles[[1]].cube_k_repeat == before.cube_k_repeat;
    assert _Tiles[[1]].cube_n_repeat == before.cube_n_repeat;
    assert _Tiles[[1]].cube_cell_count == before.cube_cell_count;
    assert _Tiles[[1]].cube_storage_bytes == before.cube_storage_bytes;
    assert _Tiles[[1]].payload[[0]] == before.payload[[0]];
    assert _Tiles[[1]].payload[[1]] == before.payload[[1]];
    assert _Tiles[[1]].payload[[2]] == before.payload[[2]];
end;

func BeginE8M0SourceBundle(
    destination_type: TileDataType,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    physical_columns: integer {0..65535},
    destination_size: integer {1..12})
begin
    let started = ExecuteCommandInstruction(TCVTE8M0SourceStart(), 32);
    assert started == CommandExecution_Executed;
    assert TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding) ==
        TileDataType_E8M0;
    SetBundleDataAttributeState(
        TileDataTypeToEncoding(destination_type),
        Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    if physical_columns != 0 then
        SetBundleDimension(2, Zeros{PTO_XLEN} + physical_columns);
    end;
    AddBundleTileBinding(
        TRUE, 0, destination_size, '1111', TRUE, FALSE, 1, 0, TRUE);
end;

func PrepareFinalizedCubeM32Parent()
begin
    let configured = ConfigureCubeTileForMaskWithPhysical(
        1, 128, 32, 4, 1, 3, TileDataType_U8,
        TileLayout_CUBE_M32, '1111');
    assert configured;
    let slot: integer {0..63} = 7;
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].open = FALSE;
    _LocalGenerations[[slot]].closed = TRUE;
    _LocalGenerations[[slot]].last_seen = TRUE;
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1111';
    _LocalGenerations[[slot]].parent_size_code = 1;
    _LocalGenerations[[slot]].parent_cell_count = 1;
    _LocalGenerations[[slot]].working_destination = 1;
    _LocalGenerations[[slot]].published_destination = 1;
    _LocalGenerations[[slot]].writer_count = 1;
    _LocalGenerations[[slot]].writers[[0]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[0]].offset_cells = 0;
    _LocalGenerations[[slot]].writers[[0]].cell_count = 1;
    _LocalGenerations[[slot]].writers[[0]].destination = 1;
    _LocalGenerations[[slot]].writers[[0]].pe_mask = '1111';
    _LocalGenerations[[slot]].writers[[0]].ready = TRUE;
    _LocalGenerations[[slot]].writers[[0]].physical_rows = 32;
    _LocalGenerations[[slot]].writers[[0]].physical_columns = 4;
    _LocalGenerations[[slot]].writers[[0]].valid_rows = 1;
    _LocalGenerations[[slot]].writers[[0]].valid_columns = 3;
    _LocalGenerations[[slot]].writers[[0]].data_type = TileDataType_U8;
    _LocalGenerations[[slot]].writers[[0]].predicate_basis_type =
        TileDataType_U8;
    _LocalGenerations[[slot]].writers[[0]].layout = TileLayout_CUBE_M32;
    for pe = 0 to 3 do
        var one_cell = Zeros{2048};
        one_cell[0] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = one_cell;
        _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = one_cell;
        _LocalGenerations[[slot]].per_pe_published[[pe]] = TRUE;
    end;
    FinalizeBundleLocalGenerationCube(slot);
    _LocalGenerations[[slot]].published = TRUE;
    assert _LocalGenerations[[slot]].descriptor_finalized;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 4;
    assert _Tiles[[1]].valid_rows == 1 && _Tiles[[1]].valid_columns == 3;
    // Preserve the finalized published descriptor as the TCVT source while
    // ending the synthetic generation fixture's dependency-tracking lifetime.
    _LocalGenerations[[slot]].generation_identity_valid = FALSE;
end;

func CheckRowMajorToFP32()
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 8, 1, 6, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x00);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x7e);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x7f);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(1, 0, 4, Zeros{PTO_XLEN} + 0xfe);
    WriteTileElement(1, 0, 5, Zeros{PTO_XLEN} + 0xff);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];

    BeginE8M0SourceBundle(TileDataType_FP32, 1, 6, 8, 3);
    assert SelectedBundleClosedTCVTSchemaLegal(23);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x00400000;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x3f000000;
    assert ReadTileElement(destination, 0, 2) ==
        Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(destination, 0, 3) ==
        Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(destination, 0, 4) ==
        Zeros{PTO_XLEN} + 0x7f000000;
    assert ReadTileElement(destination, 0, 5) ==
        Zeros{PTO_XLEN} + 0x7fc00000;
    assert NumericStatusFlags() == Zeros{5};
    AssertE8M0SourceUnchanged(source_before);
end;

func CheckCubeM16ToBF16()
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(
        1, 128, 1, 2, TileDataType_U8, TileLayout_CUBE_M16);
    assert configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0xff);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];

    BeginE8M0SourceBundle(TileDataType_BF16, 1, 2, 0, 1);
    assert SelectedBundleClosedTCVTSchemaLegal(23);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f80;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x7fc0;
    assert NumericStatusFlags() == Zeros{5};
    AssertE8M0SourceUnchanged(source_before);
end;

func CheckFinalizedCubeM32ToFP16()
begin
    ResetProfileState();
    PrepareFinalizedCubeM32Parent();
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7e);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0xff);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];

    let destination_ready = ConfigureCubeTileForMaskWithPhysical(
        2, 256, 32, 4, 1, 3, TileDataType_FP16,
        TileLayout_CUBE_M32, '1111');
    assert destination_ready;
    let started = ExecuteCommandInstruction(TCVTE8M0SourceStart(), 32);
    assert started == CommandExecution_Executed;
    assert TileOperandsLegal_TCVT(
        2, 1, DefaultNumericExecutionControl());
    InstructionContractExecute_TCVT(
        2, 1, DefaultNumericExecutionControl());
    assert _LastFault == Fault_None;
    let destination: TileIndex = 2;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3800;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, 0, 2) ==
        Zeros{PTO_XLEN} + 0x7e00;
    assert NumericStatusFlags() == Zeros{5};
    AssertE8M0SourceUnchanged(source_before);
    assert _LocalGenerations[[7]].descriptor_finalized;
end;

func main() => integer
begin
    CheckRowMajorToFP32();
    CheckCubeM16ToBF16();
    CheckFinalizedCubeM32ToFP16();
    return 0;
end;
