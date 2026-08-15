// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","surface":"block","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMMANDS"]}
func ExecuteCommandInstruction(instruction: bits(64),
                               length_bits: integer {16,32,48,64})
                               => CommandExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    let decoded = DecodeCommandForm(instruction, length_bits);
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
    if !CommandFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    return ExecuteDecodedBundleCommand(instruction, form, length_bits);
end;
