// PTO-INSTRUCTION: {"assembly":["bse SrcL"],"block":[],"catalog_indices":[17],"catalog_records":[{"asm":"bse SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bse_32_883b5167edbc","length_bits":32,"mnemonic":"BSE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","semantic_summary":"BSE publishes the SendEvent nonblocking execution-control request.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["BSE executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["bse SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["bse SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Every assigned Reg5 source selector follows the common scalar-source availability rule."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Snapshot SrcL, publish ExecutionControl_SendEvent and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.","PTO defines no additional asleep, mailbox, timeout-counter, or pending-wake state for this nonblocking request."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-BSE","mnemonic":"BSE","summary":"BSE publishes the SendEvent nonblocking execution-control request.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSE-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// BSE MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-BSE-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BSE()
    => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BSE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BSE()
    => ExecutionControlRequest
begin
    return ExecutionControl_SendEvent;
end;

pure func InstructionContractControlRequestIsNonblocking_BSE()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
