// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGEMV-CUBE-002","source":"asl/block/execution/BSTART.TGEMV.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"execution","summary":"TGEMV consumes M16 and multi-CELL N8 Local primaries at M one","pass_condition":"K9 N10 all-one FP16 inputs publish a CUBE_M16 FP32 destination whose ten logical results equal nine","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/cube.asl"]}
func FillTGEMVCube(index: TileIndex, value: integer)
begin
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(
                tile, row as integer {0..65535},
                column as integer {0..65535});
            _Tiles[[index]].payload[[element]] =
                Zeros{PTO_XLEN} + value;
        end;
    end;
    MarkTileValidRegionDefined(index);
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 384, 1, 9,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 512, 9, 10,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    FillTGEMVCube(1, 1);
    FillTGEMVCube(2, 1);

    var start: bits(64) = Zeros{64} + 0x01031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 10);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 9);
    AddBundleTileBinding(
        TRUE, 0, 4, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();

    assert completed;
    assert _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    let d = _Tiles[[destination]];
    assert d.layout == TileLayout_CUBE_M16;
    assert d.valid_rows == 1 && d.valid_columns == 10;
    assert d.payload[[TileStorageIndex(d, 0, 0)]] ==
        Zeros{PTO_XLEN} + 9;
    assert d.payload[[TileStorageIndex(d, 0, 9)]] ==
        Zeros{PTO_XLEN} + 9;
    return 0;
end;
