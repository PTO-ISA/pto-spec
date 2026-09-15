// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-REDUCTION-BUNDLE-002","source":"asl/block/model/dispatch/reduction-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWSUM-CONTRACT-001"],"kind":"execution","summary":"Decoded direct-layout CUBE reduction bundles allocate and publish frozen M16/M32 shapes atomically.","pass_condition":"Decoded M16 and M32 TROWSUM bundles publish exact valid and physical shapes, while an undersized M32 destination raises Fault_TileAllocation without allocation or capacity consumption.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func CubeReductionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func DirectCubeLayoutAttribute(layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

func PrepareCubeReduction(source_capacity: integer {128,512,4096},
                          layout_code: bits(5),
                          valid_rows: integer {1..32},
                          valid_columns: integer {1..65535},
                          destination_size: integer {0..15})
begin
    ResetProfileState();
    let layout = if layout_code == Zeros{5} + 29 then
        TileLayout_CUBE_M32 else TileLayout_CUBE_M16;
    let configured = ConfigureCubeTile(1, source_capacity, valid_rows,
        valid_columns, TileDataType_U32, layout);
    assert configured;
    for row = 0 to valid_rows - 1 looplimit 33 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} + (row * valid_columns + column + 1));
        end;
    end;
    let started = ExecuteCommandInstruction(CubeReductionStart(), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(
        DirectCubeLayoutAttribute(layout_code), 32);
    assert attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    SetBundleDimension(2, Zeros{PTO_XLEN} + valid_columns);
    AddBundleTileBinding(
        TRUE, 0, destination_size, '1111', TRUE, FALSE, 1, 0, TRUE);
end;

func main() => integer
begin
    PrepareCubeReduction(128, Zeros{5} + 31, 2, 2, 1);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].rows == 16;
    assert _Tiles[[destination]].columns == 2;
    assert _Tiles[[destination]].contents_defined;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert TileElementDefined(destination, 0, 1);
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};

    PrepareCubeReduction(4096, Zeros{5} + 31, 2, 2, 1);
    let expanded = ExecuteBundleTileOperation();
    assert expanded;
    assert _LastFault == Fault_None;
    let expanded_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[expanded_destination]].valid_rows == 2;
    assert _Tiles[[expanded_destination]].valid_columns == 1;
    assert _Tiles[[expanded_destination]].columns == 2;
    assert _Tiles[[expanded_destination]].rows == 16;

    PrepareCubeReduction(512, Zeros{5} + 29, 16, 2, 2);
    let m32_completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert m32_completed;
    assert _LastFault == Fault_None;
    let m32_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[m32_destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[m32_destination]].valid_rows == 16;
    assert _Tiles[[m32_destination]].valid_columns == 1;
    assert _Tiles[[m32_destination]].rows == 32;
    assert _Tiles[[m32_destination]].columns == 2;
    assert ReadTileElement(m32_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(m32_destination, 15, 0) ==
        Zeros{PTO_XLEN} + 63;

    PrepareCubeReduction(512, Zeros{5} + 29, 16, 2, 1);
    let capacity_before = CoreTileCapacityInUse();
    let undersized = ExecuteBundleTileOperation();
    assert !undersized;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert CoreTileCapacityInUse() == capacity_before;
    return 0;
end;
