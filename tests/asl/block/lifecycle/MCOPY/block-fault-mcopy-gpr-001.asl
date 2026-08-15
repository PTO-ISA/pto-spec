// PTO-TEST: {"id":"PTO-AVS-BLOCK-MCOPY-GPR-001","source":"asl/block/lifecycle/MCOPY.asl","requirements":["PTO-INST-BLOCK-MCOPY"],"kind":"fault","summary":"MCOPY rejects every relative selector in each source field","pass_condition":"selectors 24 through 31 in destination, source, or length position raise Fault_IllegalInstruction before memory, progress, last-command, or TPC effects","related_sources":["asl/block/model/dispatch/commands.asl"]}
pure func MCOPYInstruction(destination: Reg5Selector, source: Reg5Selector,
                           length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + source;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func AssertMCOPYSelectorRejected(instruction: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    _LastMemoryCommandAddress = Ones{PTO_XLEN};
    _LastMemoryCommandSize = Ones{PTO_XLEN};

    let status = ExecuteCommandInstruction(instruction, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x600;
    assert _LastMemoryCommandAddress == Ones{PTO_XLEN};
    assert _LastMemoryCommandSize == Ones{PTO_XLEN};
end;

func main() => integer
begin
    for selector = 24 to 31 do
        AssertMCOPYSelectorRejected(MCOPYInstruction(selector, 0, 0));
        AssertMCOPYSelectorRejected(MCOPYInstruction(0, selector, 0));
        AssertMCOPYSelectorRejected(MCOPYInstruction(0, 0, selector));
    end;
    return 0;
end;
