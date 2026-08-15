// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QPOP-RESERVED-001","source":"asl/block/lifecycle/HL.QPOP.asl","requirements":["PTO-INST-BLOCK-HL-QPOP"],"kind":"fault","summary":"HL.QPOP reserves encoded bits 40 through 36 rather than reading a second source","pass_condition":"every nonzero reserved pattern fails decode or raises Fault_IllegalInstruction before source, queue, event, destination, or TPC effects","related_sources":["asl/block/model/dispatch/commands.asl"]}
pure func HLQPOPReservedInstruction(destination0: Reg5Selector,
                                    destination1: Reg5Selector,
                                    source_left: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x0000207d000e;
    instruction[27:23] = Zeros{5} + destination0;
    instruction[15:11] = Zeros{5} + destination1;
    instruction[35:31] = Zeros{5} + source_left;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x780);
    WriteGPR(2, Zeros{PTO_XLEN} + 0xaa);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xbb);
    for reserved = 1 to 31 do
        var instruction = HLQPOPReservedInstruction(2, 3, 24);
        instruction[40:36] = Zeros{5} + reserved;
        let status = ExecuteCommandInstruction(instruction, 48);
        assert status == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xaa;
        assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xbb;
        assert _GQMEventEpoch == 0;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x780;
        ClearFault();
    end;
    return 0;
end;
