// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-CUBE-PHYSICAL-SLACK-002","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-MGATHER-MASK-PREDICATE-001","PTO-MGATHER-CAS-ATOMIC-001","PTO-ATOM-RED-TYPE-LEGALITY-001"],"kind":"execution","summary":"Indexed TLSU preserves independent physical CUBE_M32 descriptors with row and column slack.","pass_condition":"Ordinary, masked, CAS, atomic, and reduction paths execute with physical rows above 32 and distinct non-minimum columns and capacities while retaining each participating descriptor.","related_sources":["asl/tile/model/legality/indexed-layout.asl","asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/memory/gather-scatter.asl","asl/tile/model/memory/atomics.asl","asl/tile/model/memory/gm-atom-red.asl"]}

func TestOrdinary()
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTileForMaskWithPhysical(
        0, 768, 32, 3, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32, '0001');
    let index_ready = ConfigureCubeTileForMaskWithPhysical(
        1, 1920, 32, 5, 1, 1,
        TileDataType_S32, TileLayout_CUBE_M32, '0001');
    assert destination_ready && index_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x504, 4,
        Zeros{PTO_XLEN} + 0x12345678);
    MGATHER(0, Zeros{PTO_XLEN} + 0x500, 1, TilePad_Zero);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x12345678;
    assert _Tiles[[0]].rows == 32 && _Tiles[[0]].columns == 3 &&
           _Tiles[[0]].capacity_bytes == 768;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 5 &&
           _Tiles[[1]].capacity_bytes == 1920;
end;

func TestMasked()
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTileForMaskWithPhysical(
        0, 768, 32, 3, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32, '0001');
    let index_ready = ConfigureCubeTileForMaskWithPhysical(
        1, 1920, 32, 5, 1, 1,
        TileDataType_S32, TileLayout_CUBE_M32, '0001');
    let mask_ready = ConfigureCubeTileForMaskWithPhysical(
        2, 768, 32, 12, 1, 1,
        TileDataType_U8, TileLayout_CUBE_M32, '0001');
    assert destination_ready && index_ready && mask_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x544, 4,
        Zeros{PTO_XLEN} + 0x87654321);
    MGATHER_MASK(0, Zeros{PTO_XLEN} + 0x540,
        1, 2, TilePad_Zero);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x87654321;
    assert _Tiles[[0]].rows == 32 && _Tiles[[0]].columns == 3;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 5;
    assert _Tiles[[2]].rows == 32 && _Tiles[[2]].columns == 12;
end;

func TestCAS()
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTileForMaskWithPhysical(
        0, 768, 32, 6, 1, 1,
        TileDataType_U16, TileLayout_CUBE_M32, '0001');
    let index_ready = ConfigureCubeTileForMaskWithPhysical(
        1, 1152, 32, 3, 1, 1,
        TileDataType_S32, TileLayout_CUBE_M32, '0001');
    let expected_ready = ConfigureCubeTileForMaskWithPhysical(
        2, 1024, 32, 8, 1, 1,
        TileDataType_U16, TileLayout_CUBE_M32, '0001');
    let replacement_ready = ConfigureCubeTileForMaskWithPhysical(
        3, 1152, 32, 6, 1, 1,
        TileDataType_U16, TileLayout_CUBE_M32, '0001');
    assert destination_ready && index_ready && expected_ready &&
           replacement_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 0x582, 2, Zeros{PTO_XLEN} + 7);
    MGATHER_CAS(0, Zeros{PTO_XLEN} + 0x580, 1, 2, 3);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    let cas_result = LoadUnsigned(Zeros{PTO_XLEN} + 0x582, 2);
    assert cas_result == Zeros{PTO_XLEN} + 9;
    assert _Tiles[[0]].rows == 32 && _Tiles[[0]].columns == 6;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 3;
    assert _Tiles[[2]].rows == 32 && _Tiles[[2]].columns == 8;
    assert _Tiles[[3]].rows == 32 && _Tiles[[3]].columns == 6;
end;

func TestAtomReduction()
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTileForMaskWithPhysical(
        0, 768, 32, 3, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32, '0001');
    let index_ready = ConfigureCubeTileForMaskWithPhysical(
        1, 1920, 32, 5, 1, 1,
        TileDataType_S32, TileLayout_CUBE_M32, '0001');
    let value_ready = ConfigureCubeTileForMaskWithPhysical(
        2, 1536, 32, 3, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32, '0001');
    assert destination_ready && index_ready && value_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 0x5c4, 4, Zeros{PTO_XLEN} + 10);
    GM_ATOM_VALUE(GMAtomic_ADD, 0, Zeros{PTO_XLEN} + 0x5c0,
        1, 2, TilePad_Null);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 10;
    let atom_result = LoadUnsigned(Zeros{PTO_XLEN} + 0x5c4, 4);
    assert atom_result == Zeros{PTO_XLEN} + 15;
    Store(Zeros{PTO_XLEN} + 0x604, 4, Zeros{PTO_XLEN} + 20);
    GM_RED_VALUE(GMReduction_ADD, Zeros{PTO_XLEN} + 0x600,
        1, 2, TilePad_Null);
    let reduction_result = LoadUnsigned(Zeros{PTO_XLEN} + 0x604, 4);
    assert reduction_result == Zeros{PTO_XLEN} + 25;
    assert _Tiles[[0]].rows == 32 && _Tiles[[0]].columns == 3;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 5 &&
           _Tiles[[1]].capacity_bytes == 1920;
    assert _Tiles[[2]].rows == 32 && _Tiles[[2]].columns == 3 &&
           _Tiles[[2]].capacity_bytes == 1536;
end;

func main() => integer
begin
    TestOrdinary();
    TestMasked();
    TestCAS();
    TestAtomReduction();
    return 0;
end;
