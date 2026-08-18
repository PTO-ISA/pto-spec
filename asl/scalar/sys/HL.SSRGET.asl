// PTO-INSTRUCTION: {"assembly":["hl.ssrget SSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[283],"catalog_records":[{"asm":"hl.ssrget SSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x000ff07f000f","match":"0x0000003b000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SSR_ID","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"encoding-defined","width":24}],"form_id":"hl_ssrget_48_fde37e58a3c4","length_bits":48,"mnemonic":"HL.SSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterGet","semantic_summary":"HL.SSRGET reads the complete encoded system-register address.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["HL.SSRGET executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["hl.ssrget SSR_ID, ->{t, u, Rd}"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["hl.ssrget SSR_ID, ->{t, u, Rd}"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SSR_ID":"Encoded zero selects value zero of the system-register identifier."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination: discard, R1..R23, push U, or push T"},{"field":"SSR_ID","role":"system-register identifier"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Read the complete XLEN system-register value and publish it through the common Reg5 destination mapping.","A rejected read preserves the destination and queue state except for ordinary trap entry."]},"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS"],"id":"PTO-SCALAR-HL-SSRGET","mnemonic":"HL.SSRGET","summary":"HL.SSRGET reads the complete encoded system-register address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-SSRGET-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.SSRGET MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-HL-SSRGET-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_HL_SSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_HL_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_HL_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_HL_SSRGET()
    => integer {5,12,24}
begin
    return 24;
end;

pure func InstructionContractPushesTemporaryT_HL_SSRGET()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
