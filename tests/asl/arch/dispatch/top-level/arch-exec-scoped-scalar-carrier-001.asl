// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-CARRIER-EXECUTION-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001","PTO-INST-SCALAR-C-LWI","PTO-INST-SCALAR-C-SWI","PTO-INST-SCALAR-LD-PCR","PTO-INST-SCALAR-HL-LD-PCR","PTO-INST-SCALAR-HL-LDI-PR","PTO-INST-SCALAR-HL-SDI-PO","PTO-TSTORE-MEMORY-001"],"kind":"execution","summary":"Executes fetched and directly dispatched scoped Scalar forms across all carrier lengths, then checks Tile and legacy Scalar scope isolation.","pass_condition":"All three Shareability choices reach compressed, ordinary, long, and writeback accesses; TPC and results are preserved; following Tile requests use fixed IntraCore and unqualified Scalar requests use Private.","related_sources":["asl/scalar/model/dispatch/top-level.asl","asl/scalar/model/agu/memory.asl","asl/arch/memory-model/memory-events.asl","asl/tile/model/memory/load-store.asl","asl/arch/memory-model/atomicity.asl"]}

func BuildScopedCarrier(payload: bits(48), length_code: bits(2),
                        scope_code: bits(2)) => bits(64)
begin
    var carrier: bits(64) = Zeros{64};
    carrier[63:16] = payload;
    carrier[11:10] = length_code;
    carrier[9:8] = scope_code;
    carrier[7:0] = Zeros{8} + 0x1f;
    return carrier;
end;

func WriteScopedCarrier(address: Word, carrier: bits(64))
begin
    WriteMemoryByte(address, carrier[7:0]);
    WriteMemoryByte(address + 1, carrier[15:8]);
    WriteMemoryByte(address + 2, carrier[23:16]);
    WriteMemoryByte(address + 3, carrier[31:24]);
    WriteMemoryByte(address + 4, carrier[39:32]);
    WriteMemoryByte(address + 5, carrier[47:40]);
    WriteMemoryByte(address + 6, carrier[55:48]);
    WriteMemoryByte(address + 7, carrier[63:56]);
end;

func RunScopedLoad(payload: bits(48), length_code: bits(2),
                   scope_code: bits(2), expected_scope: MemoryShareability,
                   size_bytes: integer {4,8}, expected_value: Word,
                   compressed_destination: boolean,
                   destination: integer {0..31}, via_fetch: boolean)
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let target = Zeros{PTO_XLEN} + 0x900;
    let carrier = BuildScopedCarrier(payload, length_code, scope_code);
    WriteTPC(entry);
    WriteGPR(1, target);
    Store(target, size_bytes, expected_value);
    WriteScopedCarrier(entry, carrier);
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(target, size_bytes, expected_value);

    let before_cycle = _SystemRegisters.cycle;
    var status = PTOInstruction_Rejected;
    if via_fetch then
        status = ExecuteNextPTOInstruction();
    else
        status = ExecutePTOInstruction(carrier, 64);
    end;

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == before_cycle + 1;
    assert ReadTPC() == entry + 8;
    if compressed_destination then
        assert ReadTemporaryQueue(TRUE, 0) == expected_value;
    else
        assert ReadGPR(destination as GPRIndex) == expected_value;
    end;
    assert _MemoryEventCount == 2;
    let load = _MemoryEvents[[1]];
    assert load.kind == MemoryEvent_Load;
    assert load.request_class == MemoryRequestClass_Scalar;
    assert load.shareability == expected_scope;
    assert load.address == target;
    assert load.size_bytes == size_bytes;
    assert load.read_from == (0 as MemoryEventIndex);
    assert MemoryEventsShareabilityCompatible(
        _MemoryEvents[[0]], load);
    assert MemoryExecutionAllowedRC();
    assert _CurrentMemoryShareability == MemoryShareability_Private;
    assert _CurrentMemoryRequestClass == MemoryRequestClass_Scalar;
end;

func RunScopedCompressedStore(scope_code: bits(2),
                              expected_scope: MemoryShareability)
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let target = Zeros{PTO_XLEN} + 0x900;
    let stored = Zeros{PTO_XLEN} + 0x12345678;
    var payload: bits(48) = Zeros{48} + 0x2a;
    payload[10:6] = Zeros{5} + 1;
    var carrier = BuildScopedCarrier(payload, '00', scope_code);
    WriteTPC(entry);
    WriteGPR(1, target);
    _TQueue[[0]] = stored;
    _TQueueValid[[0]] = TRUE;
    WriteScopedCarrier(entry, carrier);
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(target, 4, Zeros{PTO_XLEN});

    let before_cycle = _SystemRegisters.cycle;
    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == before_cycle + 1;
    assert ReadTPC() == entry + 8;
    assert LoadTranslatedUnsigned(target, 4) == stored;
    assert ReadTemporaryQueue(TRUE, 0) == stored;
    assert _MemoryEventCount == 2;
    let store = _MemoryEvents[[1]];
    assert store.kind == MemoryEvent_Store;
    assert store.request_class == MemoryRequestClass_Scalar;
    assert store.shareability == expected_scope;
    assert store.address == target;
    assert store.size_bytes == 4;
    assert _CurrentMemoryShareability == MemoryShareability_Private;
    assert _CurrentMemoryRequestClass == MemoryRequestClass_Scalar;
end;

func TestScopedPreAndPostIndexWriteback()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let base = Zeros{PTO_XLEN} + 0x900;
    let value = Zeros{PTO_XLEN} + 0x1122334455667788;
    var pre_load: bits(48) = Zeros{48} + 0x3019002e;
    pre_load[27:23] = Zeros{5} + 3;
    pre_load[15:11] = Zeros{5} + 4;
    pre_load[35:31] = Zeros{5} + 1;
    pre_load[47:36] = Zeros{12} + 1;
    WriteTPC(entry);
    WriteGPR(1, base);
    Store(base + 8, 8, value);
    WriteScopedCarrier(entry,
        BuildScopedCarrier(pre_load, '10', '10'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(base + 8, 8, value);

    let load_status = ExecuteNextPTOInstruction();
    assert load_status == PTOInstruction_Executed;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(3) == value;
    assert ReadGPR(4) == base + 8;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].address == base + 8;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_InterCore;

    ResetProfileState();
    let store_entry = Zeros{PTO_XLEN} + 0x180;
    let stored = Zeros{PTO_XLEN} + 0xaabbccddeeff0011;
    var post_store: bits(48) = Zeros{48} + 0x3059003e;
    post_store[35:31] = Zeros{5} + 2;
    post_store[40:36] = Zeros{5} + 1;
    post_store[47:41] = Zeros{7} + 1;
    post_store[15:11] = Zeros{5} + 5;
    WriteTPC(store_entry);
    WriteGPR(1, base);
    WriteGPR(2, stored);
    WriteScopedCarrier(store_entry,
        BuildScopedCarrier(post_store, '10', '01'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(base, 8, Zeros{PTO_XLEN});

    let store_status = ExecuteNextPTOInstruction();
    assert store_status == PTOInstruction_Executed;
    assert ReadTPC() == store_entry + 8;
    assert LoadTranslatedUnsigned(base, 8) == stored;
    assert ReadGPR(5) == base + 8;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].address == base;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_IntraCore;
end;

func TestCarrierScopeDoesNotLeakToTileOrLegacyScalar()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let target = Zeros{PTO_XLEN} + 0x900;
    let tile_target = Zeros{PTO_XLEN} + 0xa00;
    let loaded = Zeros{PTO_XLEN} + 0x1122334455667788;
    let tile_value = Zeros{PTO_XLEN} + 0xaabbccddeeff0011;
    var scoped_load: bits(48) = Zeros{48} + 0x3039;
    scoped_load[11:7] = Zeros{5} + 2;
    scoped_load[31:15] = Zeros{17} + 0x200;
    var legacy_load: bits(48) = scoped_load;
    legacy_load[11:7] = Zeros{5} + 3;
    legacy_load[31:15] = Zeros{17} + 0x1fe;
    WriteTPC(entry);
    Store(target, 8, loaded);
    Store(tile_target, 8, Zeros{PTO_XLEN});
    WriteScopedCarrier(entry, BuildScopedCarrier(scoped_load, '01', '10'));
    WriteMemoryByte(entry + 8, legacy_load[7:0]);
    WriteMemoryByte(entry + 9, legacy_load[15:8]);
    WriteMemoryByte(entry + 10, legacy_load[23:16]);
    WriteMemoryByte(entry + 11, legacy_load[31:24]);
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(target, 8, loaded);
    - = AddInitialWriteEvent(tile_target, 8, Zeros{PTO_XLEN});
    let before_cycle = _SystemRegisters.cycle;

    let scoped_status = ExecuteNextPTOInstruction();
    assert scoped_status == PTOInstruction_Executed;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(2) == loaded;
    assert _CurrentMemoryShareability == MemoryShareability_Private;

    let tile_store = StoreTileMemoryElement(tile_target, tile_target,
        TileDataType_U64, FALSE, tile_value);
    assert tile_store == tile_value;
    RecordTileStoreEvent(tile_target, 8, tile_store, MemoryOrder_Relaxed);
    assert _MemoryEvents[[3]].request_class == MemoryRequestClass_Tile;
    assert _MemoryEvents[[3]].shareability == MemoryShareability_IntraCore;
    assert _CurrentMemoryShareability == MemoryShareability_Private;

    let legacy_status = ExecuteNextPTOInstruction();
    assert legacy_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == entry + 12;
    assert _SystemRegisters.cycle == before_cycle + 2;
    assert ReadGPR(3) == loaded;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_InterCore;
    assert _MemoryEvents[[4]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[4]].shareability == MemoryShareability_Private;
    assert !MemoryEventsShareabilityCompatible(
        _MemoryEvents[[2]], _MemoryEvents[[4]]);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;

func main() => integer
begin
    var c_lwi: bits(48) = Zeros{48} + 0x000a;
    c_lwi[10:6] = Zeros{5} + 1;
    RunScopedLoad(c_lwi, '00', '00', MemoryShareability_Private,
        4, Zeros{PTO_XLEN} + 0x12345678, TRUE, 0, TRUE);
    RunScopedLoad(c_lwi, '00', '01', MemoryShareability_IntraCore,
        4, Zeros{PTO_XLEN} + 0x12345678, TRUE, 0, TRUE);
    RunScopedLoad(c_lwi, '00', '10', MemoryShareability_InterCore,
        4, Zeros{PTO_XLEN} + 0x12345678, TRUE, 0, TRUE);

    var ld_pcr: bits(48) = Zeros{48} + 0x3039;
    ld_pcr[11:7] = Zeros{5} + 2;
    ld_pcr[31:15] = Zeros{17} + 0x200;
    RunScopedLoad(ld_pcr, '01', '00', MemoryShareability_Private,
        8, Zeros{PTO_XLEN} + 0x1122334455667788, FALSE, 2, TRUE);
    RunScopedLoad(ld_pcr, '01', '01', MemoryShareability_IntraCore,
        8, Zeros{PTO_XLEN} + 0x1122334455667788, FALSE, 2, TRUE);
    RunScopedLoad(ld_pcr, '01', '10', MemoryShareability_InterCore,
        8, Zeros{PTO_XLEN} + 0x1122334455667788, FALSE, 2, TRUE);

    var hl_ld_pcr: bits(48) = Zeros{48} + 0x3039000e;
    hl_ld_pcr[27:23] = Zeros{5} + 3;
    hl_ld_pcr[47:31] = Zeros{17} + 0x200;
    RunScopedLoad(hl_ld_pcr, '10', '00', MemoryShareability_Private,
        8, Zeros{PTO_XLEN} + 0x8877665544332211, FALSE, 3, TRUE);
    RunScopedLoad(hl_ld_pcr, '10', '01', MemoryShareability_IntraCore,
        8, Zeros{PTO_XLEN} + 0x8877665544332211, FALSE, 3, TRUE);
    RunScopedLoad(hl_ld_pcr, '10', '10', MemoryShareability_InterCore,
        8, Zeros{PTO_XLEN} + 0x8877665544332211, FALSE, 3, TRUE);

    // Direct dispatch and fetched dispatch both accept all carrier lengths;
    // these three cases also exercise each selected scope through that API.
    RunScopedLoad(c_lwi, '00', '10', MemoryShareability_InterCore,
        4, Zeros{PTO_XLEN} + 0x12345678, TRUE, 0, FALSE);
    RunScopedLoad(ld_pcr, '01', '00', MemoryShareability_Private,
        8, Zeros{PTO_XLEN} + 0x1122334455667788, FALSE, 2, FALSE);
    RunScopedLoad(hl_ld_pcr, '10', '01', MemoryShareability_IntraCore,
        8, Zeros{PTO_XLEN} + 0x8877665544332211, FALSE, 3, FALSE);

    RunScopedCompressedStore('00', MemoryShareability_Private);
    RunScopedCompressedStore('01', MemoryShareability_IntraCore);
    RunScopedCompressedStore('10', MemoryShareability_InterCore);
    TestScopedPreAndPostIndexWriteback();
    TestCarrierScopeDoesNotLeakToTileOrLegacyScalar();
    return 0;
end;
