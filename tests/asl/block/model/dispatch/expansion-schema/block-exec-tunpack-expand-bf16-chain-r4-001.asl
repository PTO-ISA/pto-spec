// PTO-TEST: {"id":"PTO-AVS-BLOCK-TUNPACK-EXPAND-BF16-CHAIN-R4-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TUNPACK-CONTRACT-001","PTO-TROWEXPANDMUL-CONTRACT-001"],"kind":"execution","summary":"Decoded BF16 TUNPACK.U16 to TROWEXPANDMUL.BF16 chains preserve operation views and derived destination geometry in both M32 and M16.","pass_condition":"M32 publishes U16 [32,2] from BF16 [32,2]; M16 publishes U16 [16,4] from BF16 [16,4]. Each chain consumes its selected raw word as the BF16 row broadcast and publishes exact BF16 arithmetic results.","related_sources":["asl/block/model/dispatch/cell-rearrangement-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/rearrangement.asl","asl/tile/model/execution/expansion.asl"]}
pure func ChainOperationStart(code: bits(12), data_type: TileDataType)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = code[6:5];
    instruction[24:20] = code[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func ChainLayoutAttribute(layout_code: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout_code;
    return instruction;
end;

func BeginChainOperation(code: bits(12), data_type: TileDataType,
                         layout_code: bits(5))
begin
    let started = ExecuteCommandInstruction(
        ChainOperationStart(code, data_type), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(
        ChainLayoutAttribute(layout_code), 32);
    assert attributed == CommandExecution_Executed;
end;

func RunBF16TUNPACKExpandChain(layout_code: bits(5),
                               layout: TileLayout,
                               rows: integer {16,32},
                               columns: integer {2,4},
                               capacity: integer {128,512},
                               destination_size: integer {1,3})
begin
    ResetProfileState();
    let multiply_source = ConfigureCubeTile(1, capacity, rows, columns,
        TileDataType_BF16, layout);
    let unpack_source = ConfigureCubeTile(2, capacity, rows, columns,
        TileDataType_BF16, layout);
    assert multiply_source && unpack_source;
    for row = 0 to rows - 1 looplimit 32 do
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 0x3f80);
        WriteTileElement(2, row, 1, Zeros{PTO_XLEN} + 0x4000);
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + 0x3f80);
        WriteTileElement(1, row, 1, Zeros{PTO_XLEN} + 0x4040);
        if columns == 4 then
            WriteTileElement(2, row, 2, Zeros{PTO_XLEN} + 0x4040);
            WriteTileElement(2, row, 3, Zeros{PTO_XLEN} + 0x4080);
            WriteTileElement(1, row, 2, Zeros{PTO_XLEN} + 0x4000);
            WriteTileElement(1, row, 3, Zeros{PTO_XLEN} + 0x4020);
        end;
    end;

    // The high half of each BF16 source raw word becomes the low U16 result
    // element.  The other valid element is zero-filled by TUNPACK.
    BeginChainOperation(Zeros{12} + 0x078, TileDataType_U16,
        layout_code);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000202);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, destination_size, '1111',
        TRUE, FALSE, 2, 0, TRUE);
    let unpack_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x078)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(unpack_operation);
    assert SelectedBundleCellRearrangementSchemaLegal(unpack_operation);
    let unpacked = ExecuteBundleTileOperation();
    assert unpacked && _LastFault == Fault_None;
    let intermediate = _BundleTileBindings[[0]].destination;
    assert _Tiles[[intermediate]].data_type == TileDataType_U16;
    assert _Tiles[[intermediate]].layout == layout;
    assert _Tiles[[intermediate]].valid_rows == rows;
    assert _Tiles[[intermediate]].valid_columns == columns;
    assert ReadTileElement(intermediate, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(intermediate, 0, 1) == Zeros{PTO_XLEN};
    if columns == 4 then
        assert ReadTileElement(intermediate, 0, 2) == Zeros{PTO_XLEN} + 0x4080;
        assert ReadTileElement(intermediate, 0, 3) == Zeros{PTO_XLEN};
    end;

    // Begin a second decoded bundle while preserving both source descriptors
    // and the newly published U16 intermediate Tile.
    ResetBundleControlState();
    BeginChainOperation(Zeros{12} + 0x047, TileDataType_BF16,
        layout_code);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + rows);
    AddBundleTileBinding(TRUE, 0, destination_size, '1111',
        TRUE, TRUE, 1, intermediate, TRUE);
    let expansion_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x047)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(expansion_operation);
    assert SelectedBundleClosedExpansionSchemaLegal(expansion_operation);
    let expanded = ExecuteBundleTileOperation();
    assert expanded && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].layout == layout;
    assert _Tiles[[destination]].valid_rows == rows;
    assert _Tiles[[destination]].valid_columns == columns;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x40c0;
    assert ReadTileElement(destination, rows - 1, 0) ==
        Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, rows - 1, 1) ==
        Zeros{PTO_XLEN} + 0x40c0;
    if columns == 4 then
        assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 0x4080;
        assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 0x40a0;
    end;
    assert _Tiles[[1]].data_type == TileDataType_BF16;
    assert _Tiles[[intermediate]].data_type == TileDataType_U16;
    assert NumericStatusFlags() == Zeros{5};
end;

func main() => integer
begin
    RunBF16TUNPACKExpandChain(Zeros{5} + 29,
        TileLayout_CUBE_M32, 32, 2, 512, 3);
    RunBF16TUNPACKExpandChain(Zeros{5} + 31,
        TileLayout_CUBE_M16, 16, 4, 128, 1);
    return 0;
end;
