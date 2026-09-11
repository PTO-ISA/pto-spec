// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-WEIGHT-MEMORY-001","source":"asl/block/model/dispatch/weight-to-shared-execution.asl","requirements":["PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001","PTO-BSTART-TLOAD-WEIGHT-SOURCE-001","PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001"],"kind":"fault","summary":"Weight TLOAD reaches its specialized execution path with precise GM preflight faults and restartable Shared rollback.","pass_condition":"GM address wrap, translation/permission, alignment, and access faults produce no load event or partial Shared generation, preserve the prior published Shared value, and a repaired reissue publishes a complete replacement without reusing speculative payload or coverage.","related_sources":["asl/block/model/memory/weight-to-shared-gm.asl","asl/block/model/operands/shared-generation.asl","asl/arch/memory-model/fault-precision.asl"]}
func WeightMemoryStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WeightMemoryAttributes(layout: integer {10..11}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

func WeightMemoryIOR(source0: integer {0..31},
                     source1: integer {0..31},
                     source2: integer {0..31}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

func WeightMemoryShared(shared_tile_id: integer {0..63}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + shared_tile_id;
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

func InstallPriorWeightShared()
begin
    ConfigureTile(0, 16384, 1024, 16, 1, 16, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for col = 0 to 15 looplimit 16 do
        let value = if col == 0 then 0x55 else 0xAA + col;
        WriteTileElement(0, 0, col, Zeros{PTO_XLEN} + value);
    end;
    InstallSharedTile((Zeros{6} + 8) as SharedTileID, _Tiles[[0]], '0001');
end;

func SetupWeightMemory(base: Word, layout: integer {10..11},
                       shared_tile_id: integer {0..63}) => boolean
begin
    WriteGPR(2, base);
    WriteGPR(3, Zeros{64} + 16 + (1 << 16) + (1 << 32) + (1 << 40));
    WriteGPR(4, Zeros{64});
    let started = ExecuteCommandInstruction(WeightMemoryStart(), 32);
    let attributes = ExecuteCommandInstruction(
        WeightMemoryAttributes(layout), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let ior = ExecuteCommandInstruction(WeightMemoryIOR(2, 3, 4), 32);
    let shared = ExecuteCommandInstruction(WeightMemoryShared(shared_tile_id), 32);
    return ior == CommandExecution_Executed &&
           shared == CommandExecution_Executed;
end;

func SetupWeightMemoryWrap(base: Word) => boolean
begin
    WriteGPR(2, base);
    WriteGPR(3, Zeros{64} + 17 + (1 << 16) + (1 << 32) + (1 << 40));
    WriteGPR(4, Zeros{64} + (16 << 32));
    let started = ExecuteCommandInstruction(WeightMemoryStart(), 32);
    let attributes = ExecuteCommandInstruction(WeightMemoryAttributes(10), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    let ior = ExecuteCommandInstruction(WeightMemoryIOR(2, 3, 4), 32);
    let shared = ExecuteCommandInstruction(WeightMemoryShared(8), 32);
    return ior == CommandExecution_Executed &&
           shared == CommandExecution_Executed;
end;

func RejectWeightMemory(base: Word, expected_fault: FaultCode,
                        expected_address: Word) => boolean
begin
    ResetProfileState();
    InstallPriorWeightShared();
    let setup = SetupWeightMemory(base, 10, 8);
    assert setup;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let rejected = !completed && _LastFault == expected_fault &&
        _FaultAddress == expected_address && _MemoryEventCount == 0 &&
        !BundleSharedGenerationOpen((Zeros{6} + 8) as SharedTileID) &&
        ReadSharedTileWord((Zeros{6} + 8) as SharedTileID, 0) ==
            Zeros{PTO_XLEN} + 0x55;
    StopMemoryEventCapture();
    return rejected;
end;

func main() => integer
begin
    // The first lane in this K window is source ci=16 at byte offset 32.
    // Adding that offset to the aligned near-XLEN GM base wraps to address 16;
    // the wrap check must win before translation or any load event.
    ResetProfileState();
    InstallPriorWeightShared();
    let xlen_wrap_setup = SetupWeightMemoryWrap(Ones{PTO_XLEN} - 15);
    assert xlen_wrap_setup;
    StartMemoryEventCapture(0);
    let xlen_wrap = ExecuteBundleTileOperation();
    assert !xlen_wrap && _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 16;
    assert _MemoryEventCount == 0;
    assert !BundleSharedGenerationOpen((Zeros{6} + 8) as SharedTileID);
    assert ReadSharedTileWord((Zeros{6} + 8) as SharedTileID, 0) ==
        Zeros{PTO_XLEN} + 0x55;
    StopMemoryEventCapture();

    // The specialized weight handler must reject a GM address crossing the
    // bounded translated-memory boundary before reading any element.
    let wrap_rejected = RejectWeightMemory(
        Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 2), Fault_DataPage,
        Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES);
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    assert _MemoryEventCount == 0;
    assert wrap_rejected;

    // A translated address denied by the active application ring is a precise
    // access fault in the weight-specific preflight path.
    ResetProfileState();
    InstallPriorWeightShared();
    SetCurrentACR(2);
    let permission_setup = SetupWeightMemory(
        Zeros{PTO_XLEN} + 3072, 11, 8);
    assert permission_setup;
    StartMemoryEventCapture(0);
    let permission_fault = ExecuteBundleTileOperation();
    assert !permission_fault && _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 3072;
    assert _MemoryEventCount == 0;
    assert !BundleSharedGenerationOpen((Zeros{6} + 8) as SharedTileID);
    assert ReadSharedTileWord((Zeros{6} + 8) as SharedTileID, 0) ==
        Zeros{PTO_XLEN} + 0x55;
    StopMemoryEventCapture();

    // Misalignment is rejected by the same specialized GM probe before data.
    let alignment_rejected = RejectWeightMemory(
        Zeros{PTO_XLEN} + 1, Fault_DataAlignment, Zeros{PTO_XLEN} + 1);
    assert alignment_rejected;

    // A bounded-memory access fault also preserves the old Shared generation.
    let access_rejected = RejectWeightMemory(
        Zeros{PTO_XLEN} + 4096, Fault_DataPage, Zeros{PTO_XLEN} + 4096);
    assert access_rejected;

    // Repair the prior boundary failure and reissue the exact same weight
    // bundle. The retry must publish a complete replacement, not reuse a
    // speculative payload, coverage bitmap, or open generation.
    ResetProfileState();
    InstallPriorWeightShared();
    let retry_setup = SetupWeightMemory(
        Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 2), 10, 8);
    assert retry_setup;
    StartMemoryEventCapture(0);
    let first = ExecuteBundleTileOperation();
    assert !first && _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    assert _MemoryEventCount == 0;
    assert !BundleSharedGenerationOpen((Zeros{6} + 8) as SharedTileID);
    assert ReadSharedTileWord((Zeros{6} + 8) as SharedTileID, 0) ==
        Zeros{PTO_XLEN} + 0x55;
    StopMemoryEventCapture();
    assert _TrapContexts[[0]].valid;

    // Recover the failed operation, then restart at a clean operation boundary
    // with a repaired GM base and fresh destination. The prior publication stays
    // intact while the retry must not reuse speculative payload or coverage.
    WriteGPR(2, Zeros{PTO_XLEN});
    let recovered = RecoverTrapContext(0);
    assert recovered;
    assert !BundleSharedGenerationOpen((Zeros{6} + 8) as SharedTileID);
    ClearFault();
    ClearBundleHeaderState();
    let retry_setup_repaired = SetupWeightMemory(
        Zeros{PTO_XLEN}, 10, 9);
    assert retry_setup_repaired;
    StartMemoryEventCapture(0);
    let retried = ExecuteBundleTileOperation();
    assert retried;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 16;
    assert SharedTilePublished((Zeros{6} + 8) as SharedTileID);
    assert ReadSharedTileWord((Zeros{6} + 8) as SharedTileID, 0) ==
        Zeros{PTO_XLEN} + 0x55;
    assert SharedTilePublished((Zeros{6} + 9) as SharedTileID);
    assert ReadSharedTileWord((Zeros{6} + 9) as SharedTileID, 0) !=
        Zeros{PTO_XLEN} + 0x55;
    assert !BundleSharedGenerationOpen((Zeros{6} + 9) as SharedTileID);
    StopMemoryEventCapture();
    return 0;
end;
