// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-BOUNDARY-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-ARCH-MEMORY-MODEL-QUALIFIER-001"],"kind":"execution","summary":"M32 b64 Atomic TSTORE accepts both logical size boundaries and preserves qualifier completion behavior","pass_condition":"the smallest FP64 M32 ADD and largest 32x128 U64 M32 AND perform through Function 1; M16 FP64 rejects without effects; encoded aq/rl/aqrl, far and post-commit trap retain the existing completion path","related_sources":["asl/tile/model/shape/cube-double-cell.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/arch/memory-model/ordering.asl"]}

pure func AtomicBoundaryStart(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func AtomicBoundaryDATR(layout: bits(5), mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[31:29] = mode;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

pure func AtomicBoundarySource() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicBoundaryIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

pure func AtomicBoundaryCATR(acquire: boolean, release: boolean,
    far: boolean, trap: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000023;
    instruction[19] = if trap then '1' else '0';
    instruction[18] = if far then '1' else '0';
    instruction[16] = if acquire then '1' else '0';
    instruction[15] = if release then '1' else '0';
    return instruction;
end;

func StartAtomicBoundaryRequest(entry: Word, data_type: TileDataType,
    layout: bits(5), mode: bits(3), valid_rows: integer {1..32},
    valid_columns: integer {1..128}, base: Word, stride: Word,
    acquire: boolean, release: boolean, far: boolean, trap: boolean)
begin
    SelectExecutionContext(0, 0);
    WriteGPR(2, base);
    WriteGPR(3, stride);
    _PC = entry;
    _BPC = entry;
    let start = ExecuteCommandInstruction(
        AtomicBoundaryStart(data_type), 32);
    let attributes = ExecuteCommandInstruction(
        AtomicBoundaryDATR(layout, mode), 32);
    let control = ExecuteCommandInstruction(
        AtomicBoundaryCATR(acquire, release, far, trap), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    let source = ExecuteCommandInstruction(AtomicBoundarySource(), 32);
    let address = ExecuteCommandInstruction(AtomicBoundaryIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           control == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].last;
end;

func RunFP64BoundaryQualifier(acquire: boolean, release: boolean,
    far: boolean, trap: boolean, expected_order: MemoryOrder)
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x200;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let configured = ConfigureCubeTileForMaskWithPhysical(0, 32768,
        32, 128, 1, 1, TileDataType_FP64, TileLayout_CUBE_M32, '1111');
    assert configured && TileCubeDescriptorLegal(_Tiles[[0]]) &&
           TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M32,
               TileDataType_FP64);
    InstallRelativeTileFixture(0, 0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x400;
    Store(base, 8, Zeros{PTO_XLEN} + 0x4000000000000000);
    StartAtomicBoundaryRequest(entry, TileDataType_FP64,
        Zeros{5} + 24, Zeros{3}, 1, 1, base,
        Zeros{PTO_XLEN} + 8,
        acquire, release, far, trap);
    assert _BundleControlAttributes.acquire == acquire &&
           _BundleControlAttributes.release == release &&
           _BundleControlAttributes.far == far &&
           _BundleControlAttributes.trap_enabled == trap;
    StartMemoryEventCapture(0);
    let committed = CompleteBundleAt(entry + 0x40);
    if trap then
        assert !committed && _LastFault == Fault_BundlePostCommit &&
               !_BundleActive && ReadTPC() == entry + 0x40;
    else
        assert committed && _LastFault == Fault_None && !_BundleActive;
    end;
    assert _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.active && event.kind == MemoryEvent_Atomic &&
           event.committed && event.core_identity == 0 && event.agent == 0 &&
           event.address == base &&
           event.read_value == Zeros{PTO_XLEN} + 0x4000000000000000 &&
           event.write_value == Zeros{PTO_XLEN} + 0x4008000000000000 &&
           event.order == expected_order;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(base, 8);
    assert actual == Zeros{PTO_XLEN} + 0x4008000000000000;
end;

func RunLargestU64Boundary()
begin
    ResetProfileState();
    assert PTO_MODEL_MEMORY_BYTES == 65536;
    let entry = Zeros{PTO_XLEN} + 0x300;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let configured = ConfigureCubeTileForMaskWithPhysical(0, 32768,
        32, 128, 32, 128, TileDataType_U64, TileLayout_CUBE_M32, '1111');
    assert configured && TileCubeDescriptorLegal(_Tiles[[0]]) &&
           TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M32,
               TileDataType_U64);
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    for row = 0 to 31 do
        for column = 0 to 127 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile.payload[[element]] = Zeros{PTO_XLEN} + 0x8000000000000000 +
                row * 128 + column;
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = 4096;
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
    let base = Zeros{PTO_XLEN} + 4096;
    let stride = Zeros{PTO_XLEN} + 1024;
    for row = 0 to 31 do
        for column = 0 to 127 do
            Store(base + row * 1024 + column * 8, 8,
                Zeros{PTO_XLEN} + 0xffffffffffffffff);
        end;
    end;
    StartAtomicBoundaryRequest(entry, TileDataType_U64,
        Zeros{5} + 24, Zeros{3} + 3, 32, 128, base, stride,
        FALSE, FALSE, FALSE, FALSE);
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 128 &&
           _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 32;
    assert TileCubeDescriptorLegal(_Tiles[[0]]) &&
           TileElementwiseSourceContentsDefined(0) &&
           TileElementwiseSourceEncodingsValidAs(0, TileDataType_U64);
    let completed = CompleteBundleAt(entry + 0x40);
    assert completed && _LastFault == Fault_None &&
           !_MemoryEventCaptureEnabled;
    for row = 0 to 31 do
        for column = 0 to 127 do
            let expected = Zeros{PTO_XLEN} + 0x8000000000000000 +
                row * 128 + column;
            let actual = LoadUnsigned(base + row * 1024 + column * 8, 8);
            assert actual == expected;
        end;
    end;
end;

func RejectM16B64Boundary()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x500;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let configured = ConfigureCubeTileForMaskWithPhysical(0, 128,
        16, 2, 1, 1, TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert configured && TileCubeDescriptorLegal(_Tiles[[0]]) &&
           !TileCubeLayoutDataTypeSupported(TileLayout_CUBE_M16,
               TileDataType_FP64);
    InstallRelativeTileFixture(0, 0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    MarkTileValidRegionDefined(0);
    var tile = _Tiles[[0]];
    tile.data_type = TileDataType_FP64;
    _Tiles[[0]] = tile;
    let base = Zeros{PTO_XLEN} + 0x800;
    let initial = Zeros{PTO_XLEN} + 0x4000000000000000;
    Store(base, 8, initial);
    StartAtomicBoundaryRequest(entry, TileDataType_FP64,
        Zeros{5} + 25, Zeros{3}, 1, 1, base,
        Zeros{PTO_XLEN} + 8,
        FALSE, FALSE, FALSE, FALSE);
    assert !_BundleControlAttributes.atomic &&
           BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].pe_mask != Zeros{4} &&
           TileReadLogicalElement(_Tiles[[0]], 0) ==
               Zeros{PTO_XLEN} + 0x3ff0000000000000;
    StartMemoryEventCapture(0);
    let committed = CompleteBundleAt(entry + 0x40);
    let invocation = _KernelInvocationByCore[[0]];
    var completed_lifetime = FALSE;
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].core == 0 &&
           _BundleSourceLifetimes[[slot]].invocation == invocation &&
           _BundleSourceLifetimes[[slot]].completed_mask != Zeros{4} then
            completed_lifetime = TRUE;
        end;
    end;
    assert !committed && _LastFault == Fault_TileLegality &&
           _MemoryEventCount == 0 && !completed_lifetime;
    StopMemoryEventCapture();
    let untouched = LoadUnsigned(base, 8);
    assert untouched == initial;
end;

func main() => integer
begin
    RunFP64BoundaryQualifier(FALSE, FALSE, FALSE, FALSE,
        MemoryOrder_Relaxed);
    RunFP64BoundaryQualifier(TRUE, FALSE, FALSE, FALSE,
        MemoryOrder_Acquire);
    RunFP64BoundaryQualifier(FALSE, TRUE, FALSE, FALSE,
        MemoryOrder_Release);
    RunFP64BoundaryQualifier(TRUE, TRUE, TRUE, FALSE,
        MemoryOrder_AcquireRelease);
    RunFP64BoundaryQualifier(FALSE, FALSE, FALSE, TRUE,
        MemoryOrder_Relaxed);
    RunLargestU64Boundary();
    RejectM16B64Boundary();
    return 0;
end;
