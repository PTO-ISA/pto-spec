// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSET-GPR-001","source":"asl/block/lifecycle/MSET.asl","requirements":["PTO-INST-BLOCK-MSET"],"kind":"fault","summary":"MSET rejects every relative selector in each source field","pass_condition":"selectors 24 through 31 in destination, fill, or length position raise Fault_IllegalInstruction before memory, last-command state, or TPC changes","related_sources":["asl/block/model/dispatch/commands.asl"]}
pure func MSETInstruction(destination: Reg5Selector, value: Reg5Selector,
                          length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + value;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func AssertMSETSelectorRejected(instruction: bits(64))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x580);
    _LastMemoryCommandAddress = Ones{PTO_XLEN};
    _LastMemoryCommandSize = Ones{PTO_XLEN};

    let status = ExecuteCommandInstruction(instruction, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x580;
    assert _LastMemoryCommandAddress == Ones{PTO_XLEN};
    assert _LastMemoryCommandSize == Ones{PTO_XLEN};
end;

func main() => integer
begin
    for selector = 24 to 31 do
        AssertMSETSelectorRejected(MSETInstruction(selector, 0, 0));
        AssertMSETSelectorRejected(MSETInstruction(0, selector, 0));
        AssertMSETSelectorRejected(MSETInstruction(0, 0, selector));
    end;
    return 0;
end;
