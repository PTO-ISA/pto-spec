// PTO-TEST: {"id":"PTO-AVS-SCALAR-CORE-PGAS-ACCESS-001","source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-CORE-PGAS-SSR-001"],"kind":"fault","summary":"Canonical PGAS registers reject writes and swaps and preserve existing placement and reserved-address behavior","pass_condition":"encoded faulting forms preserve destinations, queues and PGAS configuration under the existing fault envelope","related_sources":["asl/scalar/sys/C.SSRGET.asl","asl/scalar/sys/HL.SSRSET.asl","asl/scalar/sys/SSRSET.asl","asl/scalar/sys/SSRSWAP.asl"]}
func main() => integer
begin
    let configured = ConfigureCorePGAS(0, 0x100000003, 0x100000009);
    assert configured;
    for attempt = 0 to 10 do
        ResetProfileState();
        SetCurrentACR(0);
        WriteTPC(Zeros{PTO_XLEN} + 0x100);
        let placement = if attempt >= 9 then BundleKind_Standard else BundleKind_System;
        BeginBundle(placement, BundleTransfer_Fallthrough,
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x180,
            Zeros{PTO_XLEN}, FALSE);
        EnterBundleBody();
        WriteGPR(3, Zeros{PTO_XLEN} + 0x333);
        WriteGPR(5, Zeros{PTO_XLEN} + 0x555);
        PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x111);
        PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x222);
        let ssrid = if attempt MOD 2 == 0 then Zeros{64} + 0x02800000
                    else Zeros{64} + 0x02900000;
        let instruction = if attempt < 2 then ssrid + 0x2903b
                          else if attempt < 4 then LSL(ssrid + 0x2903b, 16) + 0x000e
                          else if attempt == 4 then ssrid + 0x2a1bb
                          else if attempt == 5 then ssrid + 0x2afbb
                          else if attempt == 6 then Zeros{64} + 0x822c
                          else if attempt == 7 then Zeros{64} + 0x826c
                          else if attempt == 8 then Zeros{64} + 0x02a001bb
                          else if attempt == 9 then ssrid + 0x001bb
                          else ssrid + 0x2903b;
        let width = if attempt == 2 || attempt == 3 then 48
                    else if attempt == 6 || attempt == 7 then 16 else 32;
        let result = ExecutePTOInstruction(instruction, width as integer {16,32,48,64});
        assert result == PTOInstruction_Rejected;
        let expected_fault = if attempt >= 9 then Fault_BundleControl
                             else Fault_IllegalInstruction;
        assert _LastFault == expected_fault;
        assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x333;
        assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x555;
        assert _TQueueValid[[0]];
        assert _UQueueValid[[0]];
        assert !_TQueueValid[[1]];
        assert !_UQueueValid[[1]];
        assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x111;
        assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x222;
        let base_value = ReadSystemRegister(SystemRegister_CORE_PGAS_BASE);
        assert base_value ==
            Zeros{PTO_XLEN} + 0x100000003;
        let limit_value = ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT);
        assert limit_value ==
            Zeros{PTO_XLEN} + 0x100000009;
    end;
    return 0;
end;
