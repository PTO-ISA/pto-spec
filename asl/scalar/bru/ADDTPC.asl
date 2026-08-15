// PTO-INSTRUCTION: {"assembly":["addtpc simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[5],"catalog_records":[{"asm":"addtpc simm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000007","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"addtpc_32_e5aa0f0abca3","length_bits":32,"mnemonic":"ADDTPC","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"AddToPC","semantic_summary":"ADDTPC - Add the encoded displacement to the program counter.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["addtpc simm, ->{t, u, Rd}"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["addtpc simm, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","imm20":"Encoded zero supplies numeric zero for the 20-bit immediate value."},"legality":["addtpc_32_e5aa0f0abca3.RegDst excludes 10; the excluded encoding is reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"imm20","role":"20-bit immediate value"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["ADDTPC - Add the encoded displacement to the program counter.","After decode and legality checks, execute the normative AddToPC ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-ADDTPC","mnemonic":"ADDTPC","summary":"ADDTPC - Add the encoded displacement to the program counter.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_ADDTPC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;
// DOC-END: operation
