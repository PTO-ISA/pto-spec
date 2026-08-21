// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-CUBE-ACCESS-003","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"fault","summary":"CUBE TSTORE preflights first middle and last valid GM accesses before effects","pass_condition":"every fault position emits no event writes no valid prefix and preserves the complete persistent CUBE source","related_sources":["asl/tile/model/memory/load-store.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
pure func CubeAccessTStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeAccessTStoreAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    return instruction;
end;

pure func CubeAccessTStoreSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0000';
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

pure func CubeAccessTStoreIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func ConfigureCubeAccessStoreSource()
begin
    let configured = ConfigureCubeTileForMask(0, 128, 3, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '0001');
    assert configured;
    var tile = _Tiles[[0]];
    for row = 0 to 2 do
        let element = TileStorageIndex(
            tile, row as integer {0..65535}, 0);
        tile.payload[[element]] = Zeros{PTO_XLEN} + row + 1;
        tile.defined_elements[element] = '1';
    end;
    tile.defined_valid_elements = 3;
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
end;

func CubeTStoreAccessRejects(base: Word, stride: Word,
                             expected_fault_address: Word,
                             witness_address: integer {0..4095}) => boolean
begin
    ResetProfileState();
    ConfigureCubeAccessStoreSource();
    _Memory[[witness_address]] = Zeros{8} + 0xa5;
    WriteGPR(2, base);
    WriteGPR(3, stride);
    let start_status = ExecuteCommandInstruction(CubeAccessTStoreStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        CubeAccessTStoreAttributes(), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    let source_status = ExecuteCommandInstruction(
        CubeAccessTStoreSource(), 32);
    let ior_status = ExecuteCommandInstruction(CubeAccessTStoreIOR(), 32);
    if source_status != CommandExecution_Executed ||
       ior_status != CommandExecution_Executed then return FALSE; end;
    let source_before = _Tiles[[0]];
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let source_after = _Tiles[[0]];
    let first_element = TileStorageIndex(source_after, 0, 0);
    let last_element = TileStorageIndex(source_after, 2, 0);
    let rejected = !completed && _LastFault == Fault_DataPage &&
        _FaultAddress == expected_fault_address &&
        _MemoryEventCount == 0 &&
        _Memory[[witness_address]] == Zeros{8} + 0xa5 &&
        source_after.allocated && source_after.contents_defined &&
        source_after.payload[[first_element]] ==
            source_before.payload[[first_element]] &&
        source_after.payload[[last_element]] ==
            source_before.payload[[last_element]];
    StopMemoryEventCapture();
    return rejected;
end;

func main() => integer
begin
    let first = CubeTStoreAccessRejects(
        Zeros{PTO_XLEN} + 4096,
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4096,
        0);
    assert first;
    let middle = CubeTStoreAccessRejects(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x8000000000000002,
        Zeros{PTO_XLEN} + 0x8000000000000002,
        0);
    assert middle;
    let last = CubeTStoreAccessRejects(
        Zeros{PTO_XLEN} + 4092,
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4096,
        4092);
    assert last;
    return 0;
end;
