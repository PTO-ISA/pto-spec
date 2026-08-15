// PTO-INSTRUCTION: {"assembly":["assert SrcL"],"block":[],"catalog_indices":[11],"catalog_records":[{"asm":"assert SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000102b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"assert_32_f05d67874ae5","length_bits":32,"mnemonic":"ASSERT","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ArchitectureAssert","semantic_summary":"ASSERT raises the architecture assertion trap exactly when its snapshotted scalar condition is zero.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["ASSERT executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["assert SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["assert SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","Every available Reg5 source selector is assigned."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Snapshot SrcL; zero raises Fault_Assert at the faulting PC and nonzero performs no effect other than successful retirement."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-ASSERT","mnemonic":"ASSERT","summary":"ASSERT raises the architecture assertion trap exactly when its snapshotted scalar condition is zero.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ASSERT()
    => ScalarOperation
begin
    return ScalarOperation_ASSERT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ASSERT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureAssert;
end;

pure func InstructionContractRequiresSystemBlock_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFaultsWhenZero_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPreservesSource_ASSERT()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
