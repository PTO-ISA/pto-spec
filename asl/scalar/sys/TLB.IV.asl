// PTO-INSTRUCTION: {"assembly":["tlb.iv SrcL"],"block":[],"catalog_indices":[460],"catalog_records":[{"asm":"tlb.iv SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0010702b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"tlb_iv_32_bf0a5d1ea211","length_bits":32,"mnemonic":"TLB.IV","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","semantic_summary":"TLB.IV completes the canonical 48-bit virtual address maintenance operation synchronously.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["TLB.IV executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["tlb.iv SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["tlb.iv SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.","The operand must be a canonical 48-bit virtual address."],"memory_effects":["No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch."],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Success records Maintenance_TLB_IV and its exact operand token.","Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-TLB-IV","mnemonic":"TLB.IV","summary":"TLB.IV completes the canonical 48-bit virtual address maintenance operation synchronously.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TLB-IV-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0031.
// TLB.IV MUST enforce its mnemonic-owned system or maintenance access
// domain before effects and MUST preserve destination, queue, and system state
// on rejection except for the ordinary instruction-attempt trap envelope.
// NDF-END: PTO-TLB-IV-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IV()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IV()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IV;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IV()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
