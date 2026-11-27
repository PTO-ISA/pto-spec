// PTO-TEST: {"id":"PTO-AVS-SCALAR-CORE-PGAS-READ-001","source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-CORE-PGAS-RANGE-001","PTO-CORE-PGAS-SSR-001"],"kind":"state-transition","summary":"Encoded SYS reads use the static Core PGAS pair across PE selections and platform epochs","pass_condition":"both encodings return exact full-width values for all Core and PE pairs at root and non-root ACRs, with no memory events","related_sources":["asl/arch/dispatch/top-level.asl","asl/arch/system-registers/addressing.asl","asl/scalar/sys/SSRGET.asl","asl/scalar/sys/HL.SSRGET.asl"]}
func main() => integer
begin
    ResetProfileState();
    for epoch = 0 to 1 do
        if epoch == 1 then
            FinishPlatformExecutionEpoch();
            let reset = ResetPlatformExecution();
            assert reset;
            let zero_based = ConfigureCorePGAS(0, 0, 0x100000001);
            assert zero_based;
            let high_range = ConfigureCorePGAS(1, 0x200000003, 0x300000008);
            assert high_range;
        end;
        for selection = 0 to 2 do
            let core = (selection MOD PTO_MODEL_CORE_INSTANCES) as PTOModelCoreIdentity;
            let expected_base = if epoch == 0 || core == 0 then Zeros{PTO_XLEN}
                                else Zeros{PTO_XLEN} + 0x200000003;
            let expected_limit = if epoch == 0 then Zeros{PTO_XLEN}
                                 else if core == 0 then Zeros{PTO_XLEN} + 0x100000001
                                 else Zeros{PTO_XLEN} + 0x300000008;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                SelectExecutionContext(core, pe as MemoryAgentId);
                StartMemoryEventCapture(pe as MemoryAgentId);
                SetCurrentACR(pe as AccessControlRing);
                let tpc = Zeros{PTO_XLEN} + 0x180;
                BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
                    Zeros{PTO_XLEN}, tpc, Zeros{PTO_XLEN}, FALSE);
                assert _LastFault == Fault_None;
                EnterBundleBody();
                let short_base = ExecutePTOInstruction(Zeros{64} + 0x028001bb, 32);
                assert short_base == PTOInstruction_Executed;
                assert ReadGPR(3) == expected_base;
                let short_limit = ExecutePTOInstruction(Zeros{64} + 0x0290023b, 32);
                assert short_limit == PTOInstruction_Executed;
                assert ReadGPR(4) == expected_limit;
                let long_base = ExecutePTOInstruction(Zeros{64} + 0x0280023b000e, 48);
                assert long_base == PTOInstruction_Executed;
                assert ReadGPR(4) == expected_base;
                let long_limit = ExecutePTOInstruction(Zeros{64} + 0x029001bb000e, 48);
                assert long_limit == PTOInstruction_Executed;
                assert ReadGPR(3) == expected_limit;
                let t_result = ExecutePTOInstruction(Zeros{64} + 0x02800fbb, 32);
                assert t_result == PTOInstruction_Executed;
                assert _TQueueValid[[0]];
                assert ReadTemporaryQueue(TRUE, 0) == expected_base;
                let u_result = ExecutePTOInstruction(Zeros{64} + 0x02900f3b000e, 48);
                assert u_result == PTOInstruction_Executed;
                assert _UQueueValid[[0]];
                assert ReadTemporaryQueue(FALSE, 0) == expected_limit;
                assert ReadTPC() == tpc + 30;
                assert _LastFault == Fault_None;
                assert _MemoryEventCount == 0;
                StopMemoryEventCapture();
                StopBundle();
            end;
        end;
        let rejected_after_decode = ConfigureCorePGAS(0, 0, 0);
        assert !rejected_after_decode;
    end;

    // Full platform reinitialization can clear or replace a previous pair.
    FinishPlatformExecutionEpoch();
    let reset = ResetPlatformExecution();
    assert reset;
    let one_byte = ConfigureCorePGAS(1, 0, 1);
    assert one_byte;
    SelectExecutionContext(0, 2);
    let default_limit = ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT);
    assert default_limit == Zeros{PTO_XLEN};
    SelectExecutionContext(1, 2);
    let replacement_limit = ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT);
    assert replacement_limit == Zeros{PTO_XLEN} + 1;
    return 0;
end;
