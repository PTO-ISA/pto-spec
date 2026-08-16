// PTO-INSTRUCTION: {"assembly":["c.cmp.nei t#1, simm, ->t"],"block":[],"catalog_indices":[35],"catalog_records":[{"asm":"c.cmp.nei t#1, simm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x082c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_cmp_nei_16_35d1f02063e2","length_bits":16,"mnemonic":"C.CMP.NEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","semantic_summary":"C.CMP.NEI - Compare scalar operands and write the encoded boolean result.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["c.cmp.nei t#1, simm, ->t"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["c.cmp.nei t#1, simm, ->t"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"simm5":"Encoded zero supplies numeric zero for the 5-bit signed immediate."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"simm5","role":"5-bit signed immediate"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["C.CMP.NEI - Compare scalar operands and write the encoded boolean result.","After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-CMP-NEI","mnemonic":"C.CMP.NEI","summary":"C.CMP.NEI - Compare scalar operands and write the encoded boolean result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_NEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_C_CMP_NEI()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCompareResult_C_CMP_NEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_CMP_NEI(),
        left,
        right);
end;
// DOC-END: operation
