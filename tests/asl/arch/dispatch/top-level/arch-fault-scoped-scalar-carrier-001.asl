// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-CARRIER-REJECT-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001"],"kind":"fault","summary":"Rejects malformed, reserved, and excluded Shareability carriers before effects.","pass_condition":"Reserved scope/length, nonzero inner padding, DMA, and Prefetch all raise one illegal-instruction attempt without memory, GPR, queue, or TPC effects.","related_sources":["asl/scalar/model/dispatch/top-level.asl","asl/scalar/amo/DMA.asl","asl/scalar/agu/PRF.asl"]}

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

func AssertRejectedWithoutEffects(carrier: bits(64))
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0x900;
    WriteTPC(entry);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x55);
    WriteGPR(3, address);
    Store(address, 8, Zeros{PTO_XLEN} + 0x1122334455667788);
    _TQueue[[0]] = Zeros{PTO_XLEN} + 0x77;
    _TQueueValid[[0]] = TRUE;
    StartMemoryEventCapture(0);

    let before_cycle = _SystemRegisters.cycle;
    let status = ExecutePTOInstruction(carrier, 64);

    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _SystemRegisters.cycle == before_cycle + 1;
    assert ReadTPC() == entry;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x55;
    assert ReadGPR(3) == address;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x77;
    assert LoadTranslatedUnsigned(address, 8) ==
        Zeros{PTO_XLEN} + 0x1122334455667788;
    assert _MemoryEventCount == 0;
end;

func main() => integer
begin
    var compressed: bits(48) = Zeros{48} + 0x004a;
    var invalid_scope = BuildScopedCarrier(compressed, '00', '11');
    AssertRejectedWithoutEffects(invalid_scope);

    var invalid_length = BuildScopedCarrier(compressed, '11', '01');
    AssertRejectedWithoutEffects(invalid_length);

    compressed[20] = '1';
    var invalid_padding = BuildScopedCarrier(compressed, '00', '01');
    AssertRejectedWithoutEffects(invalid_padding);

    var dma: bits(48) = Zeros{48} + 0x700b;
    var excluded_dma = BuildScopedCarrier(dma, '01', '01');
    AssertRejectedWithoutEffects(excluded_dma);

    var prefetch: bits(48) = Zeros{48} + 0x7009;
    var excluded_prefetch = BuildScopedCarrier(prefetch, '01', '10');
    AssertRejectedWithoutEffects(excluded_prefetch);
    return 0;
end;
