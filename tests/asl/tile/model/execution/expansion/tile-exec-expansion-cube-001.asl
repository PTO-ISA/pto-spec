// PTO-TEST: {"id":"PTO-AVS-TILE-EXPANSION-CUBE-001","source":"asl/tile/model/execution/expansion.asl","requirements":["PTO-TROWEXPAND-CONTRACT-001","PTO-TCOLEXPAND-CONTRACT-001","PTO-TEXPANDS-CONTRACT-001"],"kind":"execution","summary":"CUBE expansion uses logical broadcast extents, preserves same-layout legality and raw COPY carriers, and permits capacities above 2KB; TEXPANDS selects a new CUBE destination layout.","pass_condition":"A CUBE_M16 row broadcast with physical columns greater than one executes, mixed layouts reject, a 4KB expansion source is accepted, raw TF32 COPY carriers are preserved, and scalar expansion fills an explicit CUBE_M32 destination.","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/operand-schema.asl"]}
func FillTile(index: TileIndex, rows: integer {1..65535},
              columns: integer {1..65535}, value: Word)
begin
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to columns - 1 looplimit 65536 do
            WriteTileElement(index,
                row as integer {0..65535},
                column as integer {0..65535}, value);
        end;
    end;
end;

func TestCubeExpansion()
begin
    let source = ConfigureCubeTile(0, 4096, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let broadcast_ok = ConfigureCubeTile(1, 4096, 2, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let destination = ConfigureCubeTile(2, 4096, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source && broadcast_ok && destination;
    assert _Tiles[[1]].columns > 1;
    FillTile(0, 2, 2, Zeros{PTO_XLEN} + 10);
    FillTile(1, 2, 1, Zeros{PTO_XLEN} + 3);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD, TileAxis_Row, 2, 0, 1);
    ExecuteTileExpand(TileExpand_ADD, TileAxis_Row, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 13;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 13;

    let mixed_destination = ConfigureCubeTile(3, 256, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32, TileLocation_Matrix);
    assert mixed_destination;
    assert !TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD, TileAxis_Row, 3, 0, 1);

    let raw_source = ConfigureCubeTile(5, 128, 2, 1,
        TileDataType_TF32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let raw_destination = ConfigureCubeTile(6, 128, 2, 2,
        TileDataType_TF32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert raw_source && raw_destination;
    FillTile(5, 2, 1, Zeros{PTO_XLEN} + 0x3f800001);
    assert !TileNumericEncodingValid(
        TileDataType_TF32, Zeros{PTO_XLEN} + 0x3f800001);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY, TileAxis_Row, 6, 5, 5);
    ExecuteTileExpand(TileExpand_COPY, TileAxis_Row, 6, 5, 5);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(6, 1, 1) == Zeros{PTO_XLEN} + 0x3f800001;

    let scalar_destination = ConfigureCubeTile(4, 4096, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32, TileLocation_Matrix);
    assert scalar_destination;
    assert TileOperandsLegal_ExecuteTileFillScalar(
        4, Zeros{PTO_XLEN} + 7);
    ExecuteTileFillScalar(4, Zeros{PTO_XLEN} + 7);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(4, 1, 1) == Zeros{PTO_XLEN} + 7;
end;

func main() => integer
begin
    ResetProfileState();
    TestCubeExpansion();
    return 0;
end;
