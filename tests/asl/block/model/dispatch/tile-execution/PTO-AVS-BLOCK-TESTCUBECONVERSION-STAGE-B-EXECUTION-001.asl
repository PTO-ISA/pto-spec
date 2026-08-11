// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTCUBECONVERSION-STAGE-B-EXECUTION-001","source":"asl/block/model/dispatch/tile-execution.asl","requirements":["PTO-INST-BLOCK-B-DATR","PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-BLOCK-BSTART-TSTORE","PTO-INST-TILE-TLOAD","PTO-INST-TILE-TSTORE"],"kind":"execution","summary":"decoded Stage B GM/Local CUBE conversions preserve raw elements and reject invalid direction or faulting accesses","pass_condition":"TestCubeConversionStageB completes without assertion failure","related_sources":[]}
pure func BundleTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestDATR(layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[11:7] = layout;
    return instruction;
end;

pure func BundleTestTileDestinationV5(tile_size: bits(3),
                                      destination: bits(2),
                                      pe_mask: bits(4), last: boolean)
                                      => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestTileSourceV5(tile_size: bits(3), source: bits(6),
                                 pe_mask: bits(4), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = tile_size;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestSharedBindingV6(shared_id: bits(8),
                                   tile_size: bits(3),
                                   pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = tile_size;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5))
                                  => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

func TestDecodedCubeLoadOne(layout_code: bits(5), data_type_code: bits(5),
                            expected_layout: TileLayout,
                            expected: bits(PTO_XLEN))
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN} + 0x300, 1, expected);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    let start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', data_type_code), 32);
    let datr = ExecuteCommandInstruction(BundleTestDATR(layout_code), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    let ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert start == CommandExecution_Executed;
    assert datr == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    assert ior == CommandExecution_Executed;
    let stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert stop == CommandExecution_Executed;
    let loaded = _BundleTileBindings[[0]].destination;
    assert _Tiles[[loaded]].layout == expected_layout;
    assert _Tiles[[loaded]].contents_defined;
    if TileDataTypeIsFourBit(BundleTileDataType(data_type_code)) then
        assert ReadTileElement(loaded, 0, 0) ==
            ZeroExtend{PTO_XLEN}(expected[3:0]);
    else
        assert ReadTileElement(loaded, 0, 0) == expected;
    end;
end;

func TestDecodedCubeStoreOne(layout_code: bits(5), data_type_code: bits(5),
                             expected_layout: TileLayout,
                             expected: bits(PTO_XLEN))
begin
    ResetProfileState();
    let data_type = BundleTileDataType(data_type_code);
    ConfigureCubeTile(0, 128, 1, 1, data_type, expected_layout,
        TileLocation_Matrix);
    WriteTileElement(0, 0, 0, expected);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x400);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    let start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', data_type_code), 32);
    let datr = ExecuteCommandInstruction(BundleTestDATR(layout_code), 32);
    let source = ExecuteCommandInstruction(BundleTestTileSourceV5(
        '000', Zeros{6}, '1111', TRUE), 32);
    let ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert start == CommandExecution_Executed;
    assert datr == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    assert ior == CommandExecution_Executed;
    let stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert stop == CommandExecution_Executed;
    let stored = LoadUnsigned(Zeros{PTO_XLEN} + 0x400,
        TileMemoryElementBytes(data_type));
    if TileDataTypeIsFourBit(data_type) then
        assert stored[3:0] == expected[3:0];
    else
        assert stored == expected;
    end;
end;

func TestDecodedCubeLayoutAndWidthMatrix()
begin
    // Every architectural layout spelling is exercised through decoded
    // BSTART/B.DATR/B.IOT/B.IOR/BSTOP, with all four CELL width classes.
    TestDecodedCubeLoadOne('10101', '00001', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10101', '00100', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10101', '11011', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10101', '11100', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10110', '00001', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10110', '00100', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10110', '11011', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10110', '11100', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10111', '00001', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10111', '00100', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10111', '11011', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeLoadOne('10111', '11100', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11000', '00001', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11000', '00100', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11000', '11011', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11000', '11100', TileLayout_CUBE_M32,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11001', '00001', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11001', '00100', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11001', '11011', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11001', '11100', TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11010', '00001', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11010', '00100', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11010', '11011', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
    TestDecodedCubeStoreOne('11010', '11100', TileLayout_CUBE_N8,
        Zeros{PTO_XLEN} + 0x5a);
end;

func TestDecodedCubeM32LoadStore()
begin
    ResetProfileState();
    // FP32 raw words are loaded from an ordinary GM rectangle into four
    // M32 CELLs (K=4), then stored back through the inverse spelling.
    Store(Zeros{PTO_XLEN} + 0x100, 4, Zeros{PTO_XLEN} + 0x3f800001);
    Store(Zeros{PTO_XLEN} + 0x104, 4, Zeros{PTO_XLEN} + 0x3f800002);
    Store(Zeros{PTO_XLEN} + 0x108, 4, Zeros{PTO_XLEN} + 0x3f800003);
    Store(Zeros{PTO_XLEN} + 0x10c, 4, Zeros{PTO_XLEN} + 0x3f800004);
    Store(Zeros{PTO_XLEN} + 0x110, 4, Zeros{PTO_XLEN} + 0x3f800005);
    Store(Zeros{PTO_XLEN} + 0x114, 4, Zeros{PTO_XLEN} + 0x3f800006);
    Store(Zeros{PTO_XLEN} + 0x118, 4, Zeros{PTO_XLEN} + 0x3f800007);
    Store(Zeros{PTO_XLEN} + 0x11c, 4, Zeros{PTO_XLEN} + 0x3f800008);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 1), 32);
    assert load_start == CommandExecution_Executed;
    let load_datr = ExecuteCommandInstruction(BundleTestDATR('10101'), 32);
    assert load_datr == CommandExecution_Executed;
    assert CurrentBundleTileLayout() == TileLayout_CUBE_M32;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let load_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('011', '00', '1111', TRUE), 32);
    assert load_destination == CommandExecution_Executed;
    let load_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert load_ior == CommandExecution_Executed;
    let load_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert load_stop == CommandExecution_Executed;
    let loaded = _BundleTileBindings[[0]].destination;
    assert _Tiles[[loaded]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(loaded, 0, 0) == Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(loaded, 1, 3) == Zeros{PTO_XLEN} + 0x3f800008;

    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 1), 32);
    assert store_start == CommandExecution_Executed;
    let store_datr = ExecuteCommandInstruction(BundleTestDATR('11000'), 32);
    assert store_datr == CommandExecution_Executed;
    let store_source = ExecuteCommandInstruction(BundleTestTileSourceV5(
        '000', Zeros{6} + loaded, '1111', TRUE), 32);
    assert store_source == CommandExecution_Executed;
    let store_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert store_ior == CommandExecution_Executed;
    let store_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert store_stop == CommandExecution_Executed;
    let stored_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert stored_first == Zeros{PTO_XLEN} + 0x3f800001;
    let stored_padding = LoadUnsigned(Zeros{PTO_XLEN} + 0x240, 4);
    assert stored_padding == Zeros{PTO_XLEN};
end;

func TestCubeConversionBoundariesAndFaults()
begin
    // All four supported element-width classes have a legal CELL mapping;
    // b64 has no CELL mapping and is rejected before any memory effect.
    assert TileCubeKPerCell(TileLayout_CUBE_M32, TileDataType_FP32) == 1;
    assert TileCubeKPerCell(TileLayout_CUBE_M32, TileDataType_FP16) == 2;
    assert TileCubeKPerCell(TileLayout_CUBE_M32, TileDataType_U8) == 4;
    assert TileCubeKPerCell(TileLayout_CUBE_M16, TileDataType_U4X2) == 16;
    assert TileCubeKPerCell(TileLayout_CUBE_N8, TileDataType_U4X2) == 32;
    assert TileCubeKPerCell(TileLayout_CUBE_M32, TileDataType_FP64) == 0;
    assert !TileCubeDescriptorShapeLegal(128, 1, 1, TileDataType_FP64,
        TileLayout_CUBE_M32);
    assert TileCubeCellCount(TileLayout_CUBE_N8, 13, 19,
        TileDataType_FP16) == 6;
    assert TileCubeRequiredBytes(TileLayout_CUBE_N8, 13, 19,
        TileDataType_FP16) == 768;

    // The decoded b64 conversion is rejected during destination-shape
    // preflight, before a Local descriptor is allocated.
    ResetProfileState();
    let b64_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5}), 32);
    let b64_datr = ExecuteCommandInstruction(BundleTestDATR('10101'), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let b64_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    let b64_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert b64_start == CommandExecution_Executed;
    assert b64_datr == CommandExecution_Executed;
    assert b64_destination == CommandExecution_Executed;
    assert b64_ior == CommandExecution_Executed;
    let b64_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert b64_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // TLOAD preflight faults transactionally: the destination remains
    // unallocated and the first valid memory location is unchanged.
    ResetProfileState();
    _Memory[[0xfff]] = Zeros{8} + 0xaa;
    WriteGPR(2, Zeros{PTO_XLEN} + 0xfff);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    let fault_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 27), 32);
    assert fault_start == CommandExecution_Executed;
    let fault_datr = ExecuteCommandInstruction(BundleTestDATR('10101'), 32);
    assert fault_datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let fault_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    assert fault_destination == CommandExecution_Executed;
    let fault_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert fault_ior == CommandExecution_Executed;
    let fault_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert fault_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _Memory[[0xfff]] == Zeros{8} + 0xaa;

    // Direct TLSU execution supplements the decoded path with an explicit
    // precise-fault witness: the valid first byte is read only during
    // preflight, so no payload or memory effect is published.
    ResetProfileState();
    ConfigureCubeTile(0, 128, 1, 2, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Any);
    _Memory[[0xfff]] = Zeros{8} + 0xaa;
    TLOAD(0, Zeros{PTO_XLEN} + 0xfff, Zeros{PTO_XLEN} + 1);
    assert _LastFault == Fault_DataPage;
    assert _Memory[[0xfff]] == Zeros{8} + 0xaa;
    assert !_Tiles[[0]].contents_defined;

    // Wrong direction and reserved encodings fail in complete-bundle
    // preflight, before a source or destination can be consumed.
    ResetProfileState();
    let wrong_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 1), 32);
    assert wrong_start == CommandExecution_Executed;
    let wrong_datr = ExecuteCommandInstruction(BundleTestDATR('10101'), 32);
    assert wrong_datr == CommandExecution_Executed;
    let wrong_source = ExecuteCommandInstruction(BundleTestTileSourceV5(
        '000', Zeros{6}, '1111', TRUE), 32);
    assert wrong_source == CommandExecution_Executed;
    let wrong_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert wrong_stop == CommandExecution_Rejected;
    assert _LastFault != Fault_None;
    ClearFault();
    ResetBundleControlState();
    let reserved_datr = ExecuteCommandInstruction(BundleTestDATR('11111'), 32);
    assert reserved_datr == CommandExecution_Rejected;
    assert _LastFault != Fault_None;

    // Cube conversion layouts are local-only: the decoded GM-to-Shared and
    // Local-to-Shared paths reject them before either binding is consumed.
    ResetProfileState();
    let shared_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 1), 32);
    let shared_load_datr = ExecuteCommandInstruction(
        BundleTestDATR('10101'), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let shared_load_binding = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 31, '001', '1111'), 32);
    let shared_load_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert shared_load_start == CommandExecution_Executed;
    assert shared_load_datr == CommandExecution_Executed;
    assert shared_load_binding == CommandExecution_Executed;
    assert shared_load_ior == CommandExecution_Executed;
    let shared_load_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert shared_load_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;

    ResetProfileState();
    ConfigureCubeTile(0, 512, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    let shared_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 1), 32);
    let shared_store_datr = ExecuteCommandInstruction(
        BundleTestDATR('10101'), 32);
    let shared_store_binding = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 32, '001', '1111'), 32);
    let shared_store_source = ExecuteCommandInstruction(BundleTestTileSourceV5(
        '000', Zeros{6}, '1111', TRUE), 32);
    assert shared_store_start == CommandExecution_Executed;
    assert shared_store_datr == CommandExecution_Executed;
    assert shared_store_binding == CommandExecution_Executed;
    assert shared_store_source == CommandExecution_Executed;
    let shared_store_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert shared_store_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
end;

func main() => integer
begin
    ResetProfileState();
    TestDecodedCubeLayoutAndWidthMatrix();
    TestDecodedCubeM32LoadStore();
    TestCubeConversionBoundariesAndFaults();
    return 0;
end;
