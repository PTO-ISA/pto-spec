// PTO-INSTRUCTION: {"assembly":["tlb.iall"],"block":[],"catalog_indices":[458],"catalog_records":[{"asm":"tlb.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0030702b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"tlb_iall_32_0fb421b85c88","length_bits":32,"mnemonic":"TLB.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","semantic_summary":"TLB.IALL completes the all translation entries maintenance operation synchronously.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["TLB.IALL executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["tlb.iall"],"defaults":["This form has no operand; the semantic operand is the all-zero XLEN value."],"encoding_class":"standalone-encoded","examples":["tlb.iall"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation."],"memory_effects":["No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch."],"operands":[],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Success records Maintenance_TLB_IALL and its exact operand token.","Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-TLB-IALL","mnemonic":"TLB.IALL","summary":"TLB.IALL completes the all translation entries maintenance operation synchronously.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TLB-IALL-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0031.
// TLB.IALL MUST enforce its mnemonic-owned system or maintenance access
// domain before effects and MUST preserve destination, queue, and system state
// on rejection except for the ordinary instruction-attempt trap envelope.
// NDF-END: PTO-TLB-IALL-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IALL()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IALL()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IALL()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
