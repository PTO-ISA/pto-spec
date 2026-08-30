// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-TOP-LEVEL","surface":"arch","classification":["dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"]}
// PTO-REQ-INSTRUCTION-DISPATCH-001: total PTO encoded-instruction entry point.

type PTOInstructionExecutionStatus of enumeration {
    PTOInstruction_Executed,
    PTOInstruction_Rejected
};

// The ASL step boundary owns instruction fetch and length selection.  A zero
// length means that no instruction length could be selected because the PC or
// initial fetch failed.
type PTOInstructionStepResult of record {
    status: PTOInstructionExecutionStatus,
    instruction: bits(64),
    length_bits: integer {0,16,32,48,64},
    pc_before: Word,
    pc_after: Word,
    bpc_before: Word,
    bpc_after: Word,
    fault: FaultCode,
    fault_address: Word,
    current_pe: MemoryAgentId
};

readonly func PTOInstructionLengthFromHalfword(halfword: bits(16))
    => integer {16,32,48,64}
begin
    if halfword[3:1] == '111' then
        return if halfword[0] == '1' then 64 else 48;
    end;
    return if halfword[0] == '1' then 32 else 16;
end;

readonly func PTOInstructionFetchSize(
    length_bits: integer {16,32,48,64}) => integer {2,4,6,8}
begin
    case length_bits of
        when 16 => return 2;
        when 32 => return 4;
        when 48 => return 6;
        when 64 => return 8;
    end;
end;

readonly func FetchInstructionBytes(address: Word,
                                    length_bits: integer {16,32,48,64})
                                    => bits(64)
begin
    var instruction: bits(64) = Zeros{64};
    let byte_count = length_bits DIV 8;
    for byte_index = 0 to 7 do
        if byte_index < byte_count then
            let byte_address = address + NaturalToWord(
                byte_index as integer {0..262144});
            instruction[(byte_index * 8) +: 8] =
                ReadMemoryByte(byte_address);
        end;
    end;
    return instruction;
end;

func ExecuteOnePTOStep() => PTOInstructionStepResult
begin
    let pc_before = ReadTPC();
    let bpc_before = ReadBPC();
    var instruction: bits(64) = Zeros{64};
    var length_bits: integer {16,32,48,64} = 16;

    // Instruction alignment is checked before touching memory.  This is a
    // fetch failure, not a decoded instruction attempt, so the existing
    // one-tick ExecutePTOInstruction contract is not entered.
    if pc_before[0] == '1' then
        SetFault(Fault_InstructionPC, pc_before);
        return PTOInstructionStepResult {
            status = PTOInstruction_Rejected,
            instruction = instruction,
            length_bits = 0,
            pc_before = pc_before,
            pc_after = ReadTPC(),
            bpc_before = bpc_before,
            bpc_after = ReadBPC(),
            fault = _LastFault,
            fault_address = _FaultAddress,
            current_pe = _CurrentMemoryAgent
        };
    end;

    // Read only the first halfword needed to select the encoding length.
    // The complete selected range is then checked before any remaining byte
    // is read, so a truncated fetch has no partial architectural effect.
    if !InstructionAccessPermitted(pc_before, 2) then
        SetFault(Fault_InstructionPage, pc_before);
        return PTOInstructionStepResult {
            status = PTOInstruction_Rejected,
            instruction = instruction,
            length_bits = 0,
            pc_before = pc_before,
            pc_after = ReadTPC(),
            bpc_before = bpc_before,
            bpc_after = ReadBPC(),
            fault = _LastFault,
            fault_address = _FaultAddress,
            current_pe = _CurrentMemoryAgent
        };
    end;

    var halfword: bits(16) = Zeros{16};
    halfword[7:0] = ReadMemoryByte(pc_before);
    halfword[15:8] = ReadMemoryByte(pc_before + Zeros{PTO_XLEN} + 1);
    length_bits = PTOInstructionLengthFromHalfword(halfword);

    let fetch_size = PTOInstructionFetchSize(length_bits);
    if !InstructionAccessPermitted(pc_before, fetch_size) then
        SetFault(Fault_InstructionPage, pc_before);
        return PTOInstructionStepResult {
            status = PTOInstruction_Rejected,
            instruction = instruction,
            length_bits = length_bits,
            pc_before = pc_before,
            pc_after = ReadTPC(),
            bpc_before = bpc_before,
            bpc_after = ReadBPC(),
            fault = _LastFault,
            fault_address = _FaultAddress,
            current_pe = _CurrentMemoryAgent
        };
    end;

    instruction = FetchInstructionBytes(pc_before, length_bits);
    let status = ExecutePTOInstruction(instruction, length_bits);
    return PTOInstructionStepResult {
        status = status,
        instruction = instruction,
        length_bits = length_bits,
        pc_before = pc_before,
        pc_after = ReadTPC(),
        bpc_before = bpc_before,
        bpc_after = ReadBPC(),
        fault = _LastFault,
        fault_address = _FaultAddress,
        current_pe = _CurrentMemoryAgent
    };
end;

func ExecutePTOInstruction(instruction: bits(64),
                           length_bits: integer {16,32,48,64})
                           => PTOInstructionExecutionStatus
begin
    if DecodeCommandForm(instruction, length_bits) != PTO_COMMAND_FORM_COUNT then
        let command_status = ExecuteCommandInstruction(instruction, length_bits);
        if command_status == CommandExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    elsif length_bits != 64 then
        let scalar_status = ExecuteScalarInstruction(
            instruction[47:0], length_bits as integer {16,32,48});
        if scalar_status == ScalarExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    else
        BeginArchitecturalInstructionAttempt();
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return PTOInstruction_Rejected;
    end;
end;
