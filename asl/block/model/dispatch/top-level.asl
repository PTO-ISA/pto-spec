// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","surface":"block","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMMANDS"]}
func ExecuteCommandInstruction(instruction: bits(64),
                               length_bits: integer {16,32,48,64})
                               => CommandExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    // 0x0800 is emitted as C.BSTART.STD FALL in ordinary fallthrough
    // bundles, but as a compressed stop at the selecting legacy entry
    // boundary. Keep the disambiguation in ASL and context-sensitive.
    let normalized_instruction = if
        PTOModelLinxLegacyCompressedStopEnabled() && _BundleActive &&
        _BARG.block_type == BundleKind_Standard &&
        _BARG.bpcn != _BundleSequentialPC &&
        length_bits == 16 &&
        instruction[0 +: 16] == '0000100000000000'
        then Zeros{64}
        else instruction;
    let decoded = DecodeCommandForm(normalized_instruction, length_bits);
    if decoded == PTO_COMMAND_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    let handler = CommandHandlerOfForm(form);
    if _SystemBlockTerminalPending &&
       handler != CommandHandler_ExecuteBundleStop &&
       handler != CommandHandler_ExecuteBundleStart then
        SetFault(Fault_BundleControl, ReadTPC());
        return CommandExecution_Rejected;
    end;
    if !CommandFormOperandsLegal(normalized_instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    return ExecuteDecodedBundleCommand(normalized_instruction, form, length_bits);
end;
