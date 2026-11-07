// PTO-INSTRUCTION: {"assembly":["bse SrcL"],"block":[],"catalog_indices":[17],"catalog_records":[{"asm":"bse SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bse_32_883b5167edbc","length_bits":32,"mnemonic":"BSE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","semantic_summary":"BSE publishes a legacy SendEvent request or atomically admits a message for an enabled MSGB context.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["BSE executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["bse SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.","MSGB contexts reset disabled; disabled BSE retains the legacy nonblocking SendEvent request."],"encoding_class":"standalone-encoded","examples":["bse SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Every assigned Reg5 source selector follows the common scalar-source availability rule.","Enabled MSGB uses PTO-ARCH-MSGB-SEND-001: control bits 31:0 select the destination endpoint, bits 35:32 give 0..10 valid words, and bits 63:36 are reserved zero.","Enabled MSGB requires the current bound kernel context and rejects atomic/far envelopes before effects."],"memory_effects":["No direct GM payload access. Message admission alone does not make unrelated data visible to a consumer."],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success.","Enabled irreversible admission waits while earlier same-PE GM obligations may fault; this is not a payload visibility fence."],"standalone_opcode":true,"state_effects":["When MSGB is disabled, snapshot SrcL, publish ExecutionControl_SendEvent and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.","When MSGB is enabled, the message-buffer owner preflights and atomically captures staging data, allocates a transport message identity, and publishes the exact admission result.","Retries of an admitted dynamic occurrence preserve the captured message identity without another enqueue; queue backpressure and invalid controls do not allocate an identity."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS","PTO-ARCH-STATE-MESSAGE-BUFFER"],"id":"PTO-SCALAR-BSE","mnemonic":"BSE","summary":"BSE publishes a legacy SendEvent request or atomically admits a message for an enabled MSGB context.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSE-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// BSE MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic. Disabled contexts
// MUST retain the legacy request; enabled contexts MUST consume the
// message-buffer admission contract without changing the BSE encoding.
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

readonly func InstructionContractControlRequestIsNonblocking_BSE()
    => boolean
begin
    return !MessageBufferEnabledForCurrentContext();
end;
// DOC-END: operation
