// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-SPARSEFA-ADDRESS-PIPELINE-002","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-TCI-CONTRACT-001","PTO-TMULS-CONTRACT-001","PTO-TROWEXPANDADD-CONTRACT-001","PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"The CUBE TCI column sequence composes with TMULS, TROWEXPANDADD, and MGATHER for sparseFA-style multi-token byte addressing.","pass_condition":"Two independently stated CUBE_M32 U16 gather goldens cover three-token two-element and two-token four-element bursts at different section offsets, with every address formed as page base plus section offset plus column times two bytes.","related_sources":["asl/tile/tile-scalar-and-immediate/arithmetic/TMULS.asl","asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl","asl/tile/memory-and-data-movement/irregular/MGATHER.asl","asl/tile/model/execution/generation.asl","asl/tile/model/execution/elementwise.asl","asl/tile/model/execution/expansion.asl","asl/tile/model/memory/gather-scatter.asl"]}

func RunTwoElementBurst()
begin
    ResetProfileState();
    let columns_ready = ConfigureCubeTile(
        0, 256, 3, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let offsets_ready = ConfigureCubeTile(
        1, 256, 3, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let row_bases_ready = ConfigureCubeTile(
        2, 128, 3, 1, TileDataType_U32, TileLayout_CUBE_M32);
    assert columns_ready;
    assert offsets_ready;
    assert row_bases_ready;

    // TCI.COL: row step zero, column step one.
    assert TileOperandsLegal_TCICube(0, Zeros{PTO_XLEN}, Zeros{64} + 1);
    TCICube(0, Zeros{PTO_XLEN}, Zeros{64} + 1);
    assert TileElementDefined(0, 2, 0);
    assert TileElementDefined(0, 2, 1);
    assert ReadTileElement(0, 2, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 2, 1) == Zeros{PTO_XLEN} + 1;

    // U16 elements occupy two bytes.
    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_MUL, 1, 0, Zeros{PTO_XLEN} + 2);
    ExecuteTileScalar(TileBinary_MUL, 1, 0, Zeros{PTO_XLEN} + 2);
    assert TileElementDefined(1, 1, 1);
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 2;

    // The column source is dead after TMULS, so its allocation is reused for
    // the address result without changing the observable pipeline.
    let addresses_ready = ConfigureCubeTile(
        0, 256, 3, 2, TileDataType_U32, TileLayout_CUBE_M32);
    assert addresses_ready;

    // These are three independent page bases plus section offset 0x20.
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x420);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0x720);
    WriteTileElement(2, 2, 0, Zeros{PTO_XLEN} + 0xa20);
    assert TileElementDefined(2, 0, 0);
    assert TileElementDefined(2, 1, 0);
    assert TileElementDefined(2, 2, 0);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD, TileAxis_Row, 0, 1, 2);
    ExecuteTileExpand(TileExpand_ADD, TileAxis_Row, 0, 1, 2);

    // Independent address golden for three tokens and a two-element burst.
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x420;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x422;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0x720;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0x722;
    assert ReadTileElement(0, 2, 0) == Zeros{PTO_XLEN} + 0xa20;
    assert ReadTileElement(0, 2, 1) == Zeros{PTO_XLEN} + 0xa22;

    ReleaseTile(1);
    ReleaseTile(2);
    let data_ready = ConfigureCubeTile(
        3, 128, 3, 2, TileDataType_U16, TileLayout_CUBE_M32);
    assert data_ready;

    Store(Zeros{PTO_XLEN} + 0x420, 2, Zeros{PTO_XLEN} + 0x1011);
    Store(Zeros{PTO_XLEN} + 0x422, 2, Zeros{PTO_XLEN} + 0x1012);
    Store(Zeros{PTO_XLEN} + 0x720, 2, Zeros{PTO_XLEN} + 0x1021);
    Store(Zeros{PTO_XLEN} + 0x722, 2, Zeros{PTO_XLEN} + 0x1022);
    Store(Zeros{PTO_XLEN} + 0xa20, 2, Zeros{PTO_XLEN} + 0x1031);
    Store(Zeros{PTO_XLEN} + 0xa22, 2, Zeros{PTO_XLEN} + 0x1032);
    assert TileOperandsLegal_MGATHER(3, Zeros{PTO_XLEN}, 0);
    StartMemoryEventCapture(0);
    MGATHER(3, Zeros{PTO_XLEN}, 0, TilePad_Null);
    assert _MemoryEventCount == 6;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x1011;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 0x1012;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 0x1021;
    assert ReadTileElement(3, 1, 1) == Zeros{PTO_XLEN} + 0x1022;
    assert ReadTileElement(3, 2, 0) == Zeros{PTO_XLEN} + 0x1031;
    assert ReadTileElement(3, 2, 1) == Zeros{PTO_XLEN} + 0x1032;
    StopMemoryEventCapture();
end;

func RunFourElementBurst()
begin
    ResetProfileState();
    let columns_ready = ConfigureCubeTile(
        0, 512, 2, 4, TileDataType_U32, TileLayout_CUBE_M32);
    let offsets_ready = ConfigureCubeTile(
        1, 512, 2, 4, TileDataType_U32, TileLayout_CUBE_M32);
    let row_bases_ready = ConfigureCubeTile(
        2, 128, 2, 1, TileDataType_U32, TileLayout_CUBE_M32);
    assert columns_ready;
    assert offsets_ready;
    assert row_bases_ready;

    TCICube(0, Zeros{PTO_XLEN}, Zeros{64} + 1);
    ExecuteTileScalar(TileBinary_MUL, 1, 0, Zeros{PTO_XLEN} + 2);
    assert TileElementDefined(1, 1, 3);
    let addresses_ready = ConfigureCubeTile(
        0, 512, 2, 4, TileDataType_U32, TileLayout_CUBE_M32);
    assert addresses_ready;

    // These are two independent page bases plus section offset 0x80.
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0xc80);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0xe80);
    assert TileElementDefined(2, 0, 0);
    assert TileElementDefined(2, 1, 0);
    ExecuteTileExpand(TileExpand_ADD, TileAxis_Row, 0, 1, 2);
    assert TileElementDefined(0, 0, 0);
    assert TileElementDefined(0, 0, 1);
    assert TileElementDefined(0, 0, 2);
    assert TileElementDefined(0, 0, 3);
    assert TileElementDefined(0, 1, 0);
    assert TileElementDefined(0, 1, 1);
    assert TileElementDefined(0, 1, 2);
    assert TileElementDefined(0, 1, 3);

    // Independent address golden for two tokens and a four-element burst.
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xc80;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0xc82;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 0xc84;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0xc86;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0xe80;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0xe82;
    assert ReadTileElement(0, 1, 2) == Zeros{PTO_XLEN} + 0xe84;
    assert ReadTileElement(0, 1, 3) == Zeros{PTO_XLEN} + 0xe86;

    ReleaseTile(1);
    ReleaseTile(2);
    let data_ready = ConfigureCubeTile(
        3, 256, 2, 4, TileDataType_U16, TileLayout_CUBE_M32);
    assert data_ready;

    Store(Zeros{PTO_XLEN} + 0xc80, 2, Zeros{PTO_XLEN} + 0x2011);
    Store(Zeros{PTO_XLEN} + 0xc82, 2, Zeros{PTO_XLEN} + 0x2012);
    Store(Zeros{PTO_XLEN} + 0xc84, 2, Zeros{PTO_XLEN} + 0x2013);
    Store(Zeros{PTO_XLEN} + 0xc86, 2, Zeros{PTO_XLEN} + 0x2014);
    Store(Zeros{PTO_XLEN} + 0xe80, 2, Zeros{PTO_XLEN} + 0x2021);
    Store(Zeros{PTO_XLEN} + 0xe82, 2, Zeros{PTO_XLEN} + 0x2022);
    Store(Zeros{PTO_XLEN} + 0xe84, 2, Zeros{PTO_XLEN} + 0x2023);
    Store(Zeros{PTO_XLEN} + 0xe86, 2, Zeros{PTO_XLEN} + 0x2024);
    MGATHER(3, Zeros{PTO_XLEN}, 0, TilePad_Null);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x2011;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 0x2012;
    assert ReadTileElement(3, 0, 2) == Zeros{PTO_XLEN} + 0x2013;
    assert ReadTileElement(3, 0, 3) == Zeros{PTO_XLEN} + 0x2014;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 0x2021;
    assert ReadTileElement(3, 1, 1) == Zeros{PTO_XLEN} + 0x2022;
    assert ReadTileElement(3, 1, 2) == Zeros{PTO_XLEN} + 0x2023;
    assert ReadTileElement(3, 1, 3) == Zeros{PTO_XLEN} + 0x2024;
end;

func main() => integer
begin
    RunTwoElementBurst();
    RunFourElementBurst();
    return 0;
end;
