// PTO-INSTRUCTION: {"assembly":["bwt SrcL"],"block":[],"catalog_indices":[28],"catalog_records":[{"asm":"bwt SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0030002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bwt_32_5a0fe4a8e61f","length_bits":32,"mnemonic":"BWT","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","semantic_summary":"BWT publishes the WaitTimeout nonblocking execution-control request.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["BWT executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["bwt SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["bwt SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Every assigned Reg5 source selector follows the common scalar-source availability rule."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Snapshot SrcL, publish ExecutionControl_WaitTimeout and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.","PTO defines no additional asleep, mailbox, timeout-counter, or pending-wake state for this nonblocking request."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-BWT","mnemonic":"BWT","summary":"BWT publishes the WaitTimeout nonblocking execution-control request.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BWT()
    => ScalarOperation
begin
    return ScalarOperation_BWT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BWT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BWT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BWT()
    => ExecutionControlRequest
begin
    return ExecutionControl_WaitTimeout;
end;

pure func InstructionContractControlRequestIsNonblocking_BWT()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
