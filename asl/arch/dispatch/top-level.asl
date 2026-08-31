// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-TOP-LEVEL","surface":"arch","classification":["dispatch","top-level"],"depends_on":["PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"]}

// NDF-BEGIN: PTO-REQ-INSTRUCTION-DISPATCH-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// ExecutePTOInstruction is the unique encoded-instruction entry point. It MUST
// prefer an accepted 64-bit command form, dispatch non-64-bit input to scalar
// decoding, and reject an otherwise unmatched 64-bit value with
// Fault_IllegalInstruction after beginning exactly one architectural attempt.
// ExecuteNextPTOInstruction MUST fetch through PTO-REQ-INSTRUCTION-FETCH-001
// and then invoke this encoded entry point without adding another decoder.
// NDF-END: PTO-REQ-INSTRUCTION-DISPATCH-001

type PTOInstructionExecutionStatus of enumeration {
    PTOInstruction_Executed,
    PTOInstruction_Rejected
};

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

func ExecuteNextPTOInstruction() => PTOInstructionExecutionStatus
begin
    let instruction_pc = ReadTPC();

    if instruction_pc[0] == '1' then
        SetFault(Fault_InstructionPC, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let prefix_probe = ProbeInstructionAccess(instruction_pc, 2);
    if !prefix_probe.permitted then
        SetFault(Fault_InstructionPage, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let prefix = FetchPTOInstruction(prefix_probe, 16);
    let length_bits = DeterminePTOInstructionLength(prefix[15:0]);
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    let complete_probe = ProbeInstructionAccess(
        instruction_pc,
        size_bytes);
    if !complete_probe.permitted ||
       complete_probe.physical_address != prefix_probe.physical_address then
        SetFault(Fault_InstructionPage, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let instruction = FetchPTOInstruction(complete_probe, length_bits);
    return ExecutePTOInstruction(instruction, length_bits);
end;
