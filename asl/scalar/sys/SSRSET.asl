// PTO-INSTRUCTION: {"assembly":["ssrset SrcL, SSR_ID"],"block":[],"catalog_indices":[434],"catalog_records":[{"asm":"ssrset SrcL, SSR_ID","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x0000103b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"ssrset_32_4dd3b71802c6","length_bits":32,"mnemonic":"SSRSET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterSet","semantic_summary":"SSRSET writes the complete encoded system-register address.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["SSRSET executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["ssrset SrcL, SSR_ID"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["ssrset SrcL, SSR_ID"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SSR_ID":"Encoded zero selects value zero of the system-register identifier.","SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects."],"memory_effects":["none"],"operands":[{"field":"SSR_ID","role":"system-register identifier"},{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Preflight the complete address, current-ACR permission, and writable access class before reading SrcL.","Snapshot SrcL, perform the register write, and then advance TPC."],"standalone_opcode":true,"state_effects":["Write the complete XLEN source to the selected writable system register.","A rejected write preserves the source and target register except for ordinary trap entry."]},"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS"],"id":"PTO-SCALAR-SSRSET","mnemonic":"SSRSET","summary":"SSRSET writes the complete encoded system-register address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SSRSET-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0031.
// SSRSET MUST enforce its mnemonic-owned system or maintenance access
// domain before effects and MUST preserve destination, queue, and system state
// on rejection except for the ordinary instruction-attempt trap envelope.
// NDF-END: PTO-SSRSET-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SSRSET()
    => ScalarOperation
begin
    return ScalarOperation_SSRSET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SSRSET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;

pure func InstructionContractRequiresSystemBlock_SSRSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRSET()
    => bits(2)
begin
    return '01';
end;

pure func InstructionContractSystemAddressWidth_SSRSET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRSET()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
