// PTO-INSTRUCTION: {"assembly":["ssrswap SrcL, SSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[435],"catalog_records":[{"asm":"ssrswap SrcL, SSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x0000203b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"ssrswap_32_a01c7e2c7c29","length_bits":32,"mnemonic":"SSRSWAP","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterSwap","semantic_summary":"SSRSWAP atomically swaps the complete encoded system-register address.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["SSRSWAP executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["ssrswap SrcL, SSR_ID, ->{t, u, Rd}"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["ssrswap SrcL, SSR_ID, ->{t, u, Rd}"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SSR_ID":"Encoded zero selects value zero of the system-register identifier.","SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination: discard, R1..R23, push U, or push T"},{"field":"SSR_ID","role":"system-register identifier"},{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Preflight read permission, write permission, and RW access class before reading SrcL or the old register value.","Snapshot SrcL, read the old value, write the new value, publish the old value, and then advance TPC."],"standalone_opcode":true,"state_effects":["Atomically exchange the selected RW system register with the snapshotted source and publish the old value through RegDst.","A rejected swap performs neither read-side effects nor register, destination, queue, or TPC effects."]},"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS"],"id":"PTO-SCALAR-SSRSWAP","mnemonic":"SSRSWAP","summary":"SSRSWAP atomically swaps the complete encoded system-register address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SSRSWAP-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0031.
// SSRSWAP MUST enforce its mnemonic-owned system or maintenance access
// domain before effects and MUST preserve destination, queue, and system state
// on rejection except for the ordinary instruction-attempt trap envelope.
// NDF-END: PTO-SSRSWAP-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SSRSWAP()
    => ScalarOperation
begin
    return ScalarOperation_SSRSWAP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SSRSWAP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSwap;
end;

pure func InstructionContractRequiresSystemBlock_SSRSWAP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRSWAP()
    => bits(2)
begin
    return '10';
end;

pure func InstructionContractSystemAddressWidth_SSRSWAP()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRSWAP()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
