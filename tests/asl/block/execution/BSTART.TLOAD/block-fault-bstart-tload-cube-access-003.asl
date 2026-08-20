// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-ACCESS-003","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TLOAD"],"kind":"fault","summary":"CUBE TLOAD preflights first middle and last valid GM accesses before effects","pass_condition":"every fault position produces no event or destination and both live and saved bindings retain the unallocated destination hand","related_sources":["asl/tile/model/memory/load-store.asl","asl/block/model/faults/rollback.asl"]}
pure func CubeAccessTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeAccessTLoadAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func CubeAccessTLoadDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

pure func CubeAccessTLoadIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func CubeTLoadAccessRejects(base: Word, stride: Word,
                            expected_fault_address: Word) => boolean
begin
    ResetProfileState();
    WriteGPR(2, base);
    WriteGPR(3, stride);
    let start_status = ExecuteCommandInstruction(CubeAccessTLoadStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        CubeAccessTLoadAttributes(), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    let destination_status = ExecuteCommandInstruction(
        CubeAccessTLoadDestination(), 32);
    let ior_status = ExecuteCommandInstruction(CubeAccessTLoadIOR(), 32);
    if destination_status != CommandExecution_Executed ||
       ior_status != CommandExecution_Executed then return FALSE; end;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let rejected = !completed && _LastFault == Fault_DataPage &&
        _FaultAddress == expected_fault_address &&
        _MemoryEventCount == 0 && CoreTileCapacityInUse() == 0 &&
        !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
        _TrapContexts[[0]].valid &&
        !_TrapContexts[[0]].bundle_tile_bindings[[0]]
            .destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return rejected;
end;

func main() => integer
begin
    let first = CubeTLoadAccessRejects(
        Zeros{PTO_XLEN} + 4096,
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 4096);
    assert first;
    let middle = CubeTLoadAccessRejects(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x4000000000000001,
        Zeros{PTO_XLEN} + 0x8000000000000002);
    assert middle;
    let last = CubeTLoadAccessRejects(
        Zeros{PTO_XLEN} + 4092,
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 4096);
    assert last;
    return 0;
end;
