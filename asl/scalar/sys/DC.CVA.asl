// PTO-INSTRUCTION: {"assembly":["dc.cva SrcL"],"block":[],"catalog_indices":[76],"catalog_records":[{"asm":"dc.cva SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0020602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_cva_32_166d5a076f0e","length_bits":32,"mnemonic":"DC.CVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","semantic_summary":"DC.CVA completes the data-cache clean-by-address scope token maintenance operation synchronously.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["DC.CVA executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["dc.cva SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["dc.cva SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Cache maintenance is a local synchronous hint completion at every ACR."],"memory_effects":["No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch."],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Success records Maintenance_DC_CVA and its exact operand token.","Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-DC-CVA","mnemonic":"DC.CVA","summary":"DC.CVA completes the data-cache clean-by-address scope token maintenance operation synchronously.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_CVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_CVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_CVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_CVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CVA()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
