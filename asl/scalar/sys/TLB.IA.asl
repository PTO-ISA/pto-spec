// PTO-INSTRUCTION: {"assembly":["tlb.ia SrcL"],"block":[],"catalog_indices":[465],"catalog_records":[{"asm":"tlb.ia SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000702b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"tlb_ia_32_e794d6bf347e","length_bits":32,"mnemonic":"TLB.IA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","semantic_summary":"TLB.IA completes the 16-bit ASID token in bits 15:0 maintenance operation synchronously.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["TLB.IA executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["tlb.ia SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["tlb.ia SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.","Operand bits 63:16 must be zero; bits 15:0 are the ASID token."],"memory_effects":["No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch."],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Success records Maintenance_TLB_IA and its exact operand token.","Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-TLB-IA","mnemonic":"TLB.IA","summary":"TLB.IA completes the 16-bit ASID token in bits 15:0 maintenance operation synchronously.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IA()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IA()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IA;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IA()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
