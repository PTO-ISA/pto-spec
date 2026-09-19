// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-CUBE-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-TCI-CONTRACT-001"],"kind":"execution","summary":"TCI CUBE M16 and M32 materialize the typed two-dimensional sequence with exact physical columns","pass_condition":"all four integer carriers execute in both CUBE M formats, every unit row/column step tuple produces the specified logical values, and physical columns, CELL counts, bytes, and Null tails are observable","related_sources":["asl/block/model/dispatch/generation-schema.asl","asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/generation.asl","asl/tile/model/shape/cube-cell.asl"]}
pure func TCICubeStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = data_type;
    return instruction;
end;

func RunTCICube(
    data_type_code: bits(5), layout_code: bits(5), data_type: TileDataType,
    layout: TileLayout, valid_rows: integer {1..65535},
    valid_columns: integer {1..65535}, columns: integer {1..65535},
    explicit_columns: boolean, expected_cells: integer {1..16384},
    expected_bytes: integer {128..262144}, destination_size: integer {1..12},
    check_row: integer {0..65535},
    check_column: integer {0..65535}, expected: Word)
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCICubeStart(data_type_code), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, layout_code, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, NaturalToWord(valid_columns as integer {0..262144}));
    SetBundleDimension(1, NaturalToWord(valid_rows as integer {0..262144}));
    if explicit_columns then
        SetBundleDimension(2, NaturalToWord(columns as integer {0..262144}));
    end;
    AddBundleTileBinding(
        TRUE, 0, destination_size, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 0x1000);
        WritePEGPR(pe as MemoryAgentId, 5, Zeros{PTO_XLEN} + 0);
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x066)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let data_attributes_legal =
        SelectedBundleTileDataAttributesLegal(operation);
    assert data_attributes_legal;
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == data_type;
    assert _Tiles[[destination]].layout == layout;
    assert _Tiles[[destination]].valid_rows == valid_rows;
    assert _Tiles[[destination]].valid_columns == valid_columns;
    assert _Tiles[[destination]].columns == columns;
    assert _Tiles[[destination]].cube_cell_count == expected_cells;
    assert _Tiles[[destination]].cube_storage_bytes == expected_bytes;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x1000;
    assert ReadTileElement(destination, check_row, check_column) == expected;
    if valid_columns < columns then
        assert !TileElementDefined(destination, 0, valid_columns);
    end;
end;

func RunTCICubeStep(step2d: Word, expected: Word)
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        TCICubeStart(Zeros{5} + 26), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5} + 31, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 5);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, Zeros{PTO_XLEN} + 0x1000);
        WritePEGPR(pe as MemoryAgentId, 5, step2d);
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].columns == 8;
    assert _Tiles[[destination]].cube_cell_count == 2;
    assert _Tiles[[destination]].cube_storage_bytes == 256;
    assert ReadTileElement(destination, 1, 4) == expected;
end;

func RunTCICubeWrap(
    data_type_code: bits(5), layout_code: bits(5), layout: TileLayout,
    columns: integer {1..65535}, destination_size: integer {1..12},
    start: Word, expected: Word, step2d: Word,
    check_row: integer {0..65535}, check_column: integer {0..65535})
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        TCICubeStart(data_type_code), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, layout_code, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, NaturalToWord(columns as integer {0..262144}));
    AddBundleTileBinding(
        TRUE, 0, destination_size, '1111', FALSE, FALSE, 0, 0, TRUE);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
        WritePEGPR(pe as MemoryAgentId, 4, start);
        WritePEGPR(pe as MemoryAgentId, 5, step2d);
    end;
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].columns == columns;
    assert ReadTileElement(destination, 0, 0) ==
        TileRawElementValue(start, _Tiles[[destination]].data_type);
    assert ReadTileElement(destination, check_row, check_column) ==
        expected;
end;

func main() => integer
begin
    // M16 and M32 cover all four TCI integer carriers with column/K CELL
    // repetition and one fixed physical M block.
    RunTCICube(Zeros{5} + 17, Zeros{5} + 31, TileDataType_S32,
        TileLayout_CUBE_M16, 16, 3, 4, TRUE, 2, 256, 2, 15, 2,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 18, Zeros{5} + 31, TileDataType_S16,
        TileLayout_CUBE_M16, 16, 5, 8, TRUE, 2, 256, 2, 15, 4,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 25, Zeros{5} + 31, TileDataType_U32,
        TileLayout_CUBE_M16, 16, 3, 4, TRUE, 2, 256, 2, 15, 2,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 26, Zeros{5} + 31, TileDataType_U16,
        TileLayout_CUBE_M16, 16, 5, 8, TRUE, 2, 256, 2, 15, 4,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 25, Zeros{5} + 29, TileDataType_U32,
        TileLayout_CUBE_M32, 32, 2, 2, TRUE, 2, 256, 2, 31, 1,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 26, Zeros{5} + 29, TileDataType_U16,
        TileLayout_CUBE_M32, 32, 1, 2, TRUE, 1, 128, 2, 31, 0,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 17, Zeros{5} + 29, TileDataType_S32,
        TileLayout_CUBE_M32, 32, 2, 2, TRUE, 2, 256, 2, 31, 1,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 18, Zeros{5} + 29, TileDataType_S16,
        TileLayout_CUBE_M32, 32, 1, 2, TRUE, 1, 128, 2, 31, 0,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 26, Zeros{5} + 31, TileDataType_U16,
        TileLayout_CUBE_M16, 1, 1, 4, FALSE, 1, 128, 1, 0, 0,
        Zeros{PTO_XLEN} + 0x1000);
    RunTCICube(Zeros{5} + 26, Zeros{5} + 31, TileDataType_U16,
        TileLayout_CUBE_M16, 1, 1, 1024, TRUE, 256, 32768, 9, 0, 0,
        Zeros{PTO_XLEN} + 0x1000);

    RunTCICubeStep(Zeros{64} + 0xffffffffffffffff,
        Zeros{PTO_XLEN} + 0x0ffb);
    RunTCICubeStep(Zeros{64} + 0xffffffff00000000,
        Zeros{PTO_XLEN} + 0x0fff);
    RunTCICubeStep(Zeros{64} + 0xffffffff00000001,
        Zeros{PTO_XLEN} + 0x1003);
    RunTCICubeStep(Zeros{64} + 0x00000000ffffffff,
        Zeros{PTO_XLEN} + 0x0ffc);
    RunTCICubeStep(Zeros{64}, Zeros{PTO_XLEN} + 0x1000);
    RunTCICubeStep(Zeros{64} + 1,
        Zeros{PTO_XLEN} + 0x1004);
    RunTCICubeStep(Zeros{64} + 0x00000001ffffffff,
        Zeros{PTO_XLEN} + 0x0ffd);
    RunTCICubeStep(Zeros{64} + 0x0000000100000001,
        Zeros{PTO_XLEN} + 0x1005);
    RunTCICubeStep(Zeros{64} + 0x0000000100000000,
        Zeros{PTO_XLEN} + 0x1001);
    RunTCICubeWrap(Zeros{5} + 26, Zeros{5} + 31, TileLayout_CUBE_M16,
        4, 1, Zeros{PTO_XLEN} + 0xffff, Zeros{PTO_XLEN},
        Zeros{64} + 1, 0, 1);
    RunTCICubeWrap(Zeros{5} + 25, Zeros{5} + 29, TileLayout_CUBE_M32,
        2, 2, Zeros{PTO_XLEN} + 0xffffffff, Zeros{PTO_XLEN},
        Zeros{64} + 0x0000000100000000, 1, 0);
    return 0;
end;
