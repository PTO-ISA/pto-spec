// PTO-INSTRUCTION: {"assembly":["bc.iall"],"block":[],"catalog_indices":[12],"catalog_records":[{"asm":"bc.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0010402b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"bc_iall_32_fdceb48516a8","length_bits":32,"mnemonic":"BC.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","semantic_summary":"BC.IALL completes the bundle-cache all-entry scope maintenance operation synchronously.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["BC.IALL executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["bc.iall"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.","This form has no operand; the semantic operand is the all-zero XLEN value."],"encoding_class":"standalone-encoded","examples":["bc.iall"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Cache maintenance is a local synchronous hint completion at every ACR."],"memory_effects":["No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch."],"operands":[],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Success records Maintenance_BC_IALL and its exact operand token.","Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-BC-IALL","mnemonic":"BC.IALL","summary":"BC.IALL completes the bundle-cache all-entry scope maintenance operation synchronously.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_BC_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_BC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_BC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_BC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_BC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_BC_IALL()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
