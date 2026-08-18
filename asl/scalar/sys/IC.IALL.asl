// PTO-INSTRUCTION: {"assembly":["ic.iall"],"block":[],"catalog_indices":[304],"catalog_records":[{"asm":"ic.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0010502b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"ic_iall_32_854f0d4d906a","length_bits":32,"mnemonic":"IC.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","semantic_summary":"IC.IALL completes the instruction-cache all-entry scope maintenance operation synchronously.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["IC.IALL executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["ic.iall"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.","This form has no operand; the semantic operand is the all-zero XLEN value."],"encoding_class":"standalone-encoded","examples":["ic.iall"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Cache maintenance is a local synchronous hint completion at every ACR."],"memory_effects":["No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch."],"operands":[],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Success records Maintenance_IC_IALL and its exact operand token.","Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-IC-IALL","mnemonic":"IC.IALL","summary":"IC.IALL completes the instruction-cache all-entry scope maintenance operation synchronously.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_IC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_IC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_IC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_IC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_IC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_IC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_IC_IALL()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
