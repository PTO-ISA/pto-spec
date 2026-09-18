// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-CUBE-ACCESS-003","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"fault","summary":"CUBE TSTORE reports its first middle and last GM fault and retains exactly the completed store prefix","pass_condition":"each fault position keeps the stores completed before the exact fault visible in GM, leaves the persistent CUBE source unchanged, and reports the exact fault address","related_sources":["asl/tile/model/memory/load-store.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
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
        TileDataType_FP16, TileLayout_CUBE_M16, '0001');
    assert configured;
    InstallRelativeTileFixture(0, 0);
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
                             retained_events: integer {0..3}) => boolean
begin
    ResetProfileState();
    ConfigureCubeAccessStoreSource();
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
    // First-fault-only execution retains the stores completed before the
    // failing element and never modifies the persistent source.
    let rejected = !completed && _LastFault == Fault_DataPage &&
        _FaultAddress == expected_fault_address &&
        _MemoryEventCount == retained_events &&
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
        1);
    assert middle;
    // The completed first row store remains visible at the base address.
    let middle_bytes = LoadUnsigned(Zeros{PTO_XLEN}, 2);
    assert middle_bytes == Zeros{PTO_XLEN} + 1;
    let last = CubeTStoreAccessRejects(
        Zeros{PTO_XLEN} + 4092,
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 4096,
        2);
    assert last;
    // Both completed row stores remain visible before the faulting third row.
    let last_row0_bytes = LoadUnsigned(Zeros{PTO_XLEN} + 4092, 2);
    let last_row1_bytes = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 2);
    assert last_row0_bytes == Zeros{PTO_XLEN} + 1;
    assert last_row1_bytes == Zeros{PTO_XLEN} + 2;
    return 0;
end;
