// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-CUBE-002","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TSTORE","PTO-INST-TILE-TSTORE"],"kind":"execution","summary":"A decoded TSTORE block drains one persistent Local CUBE_M16 source to GM","pass_condition":"M162ND with explicit valid dimensions writes only raw valid FP16 elements and preserves the Matrix descriptor and payload","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/tile/model/memory/load-store.asl"]}
pure func CubeTStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeTStoreDataAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    instruction[28:27] = '11';
    return instruction;
end;

pure func CubeTStoreSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = '0000';
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(0, 128, 2, 3,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '0001');
    assert configured;
    var source_tile = _Tiles[[0]];
    for row = 0 to 1 do
        for column = 0 to 2 do
            let element = TileStorageIndex(source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            source_tile.payload[[element]] =
                Zeros{PTO_XLEN} + row * 3 + column + 1;
            source_tile.defined_elements[element] = '1';
        end;
    end;
    source_tile.defined_valid_elements = 6;
    source_tile.contents_defined = TRUE;
    _Tiles[[0]] = source_tile;

    let start_status = ExecuteCommandInstruction(CubeTStoreStart(), 32);
    assert start_status == CommandExecution_Executed;
    let datr_status = ExecuteCommandInstruction(
        CubeTStoreDataAttributes(), 32);
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let source_status = ExecuteCommandInstruction(CubeTStoreSource(), 32);
    assert source_status == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();

    assert completed;
    assert _LastFault == Fault_None;
    for element = 0 to 5 do
        let stored = LoadUnsigned(
            Zeros{PTO_XLEN} + element * 2, 2);
        assert stored == Zeros{PTO_XLEN} + element + 1;
    end;
    assert _Tiles[[0]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[0]].contents_defined;
    let preserved_first = TileStorageIndex(_Tiles[[0]], 0, 0);
    let preserved_last = TileStorageIndex(_Tiles[[0]], 1, 2);
    assert _Tiles[[0]].payload[[preserved_first]] ==
        source_tile.payload[[preserved_first]];
    assert _Tiles[[0]].payload[[preserved_last]] ==
        source_tile.payload[[preserved_last]];
    assert _Tiles[[0]].defined_valid_elements == 6;
    return 0;
end;
