// PTO-TEST: {"id":"PTO-AVS-SCALAR-FENCE-D-MASK-MATRIX-001","source":"asl/scalar/sys/FENCE.D.asl","requirements":["PTO-INST-SCALAR-FENCE-D","PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001"],"kind":"ordering","summary":"all 256 existing FENCE.D predecessor and successor selector pairs retain their encoded values and dispatch","pass_condition":"each pair decodes and executes as FENCE.D, advances once, invalidates the local reservation, and records the exact two four-bit masks","related_sources":["asl/scalar/model/dispatch/sys.asl","asl/arch/memory-model/atomicity.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    for predecessor = 0 to 15 do
        for successor = 0 to 15 do
            var instruction: bits(48) =
                ZeroExtend{48}(Zeros{32} + 0x0000202b);
            instruction[27:24] = Zeros{4} + predecessor;
            instruction[23:20] = Zeros{4} + successor;
            StartMemoryEventCapture(0);
            _ReservationValid = TRUE;
            let status = ExecuteScalarInstruction(instruction, 32);
            assert status == ScalarExecution_Executed;
            assert !_ReservationValid;
            assert _MemoryEventCount == 1;
            let event = _MemoryEvents[[0]];
            assert event.active;
            assert event.kind == MemoryEvent_Fence;
            assert event.agent == 0;
            assert event.fence_predecessor == Zeros{4} + predecessor;
            assert event.fence_successor == Zeros{4} + successor;
        end;
    end;
    assert _MemoryEventCount == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x600;
    StopMemoryEventCapture();
    return 0;
end;
