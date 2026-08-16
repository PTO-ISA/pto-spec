// PTO-INSTRUCTION: {"assembly":["hl.addtpc imm, ->{t, u, Rd}"],"block":[],"catalog_indices":[127],"catalog_records":[{"asm":"hl.addtpc imm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x00000007000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"encoding-defined","width":32}],"form_id":"hl_addtpc_48_2e8e692eea09","length_bits":48,"mnemonic":"HL.ADDTPC","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"AddToPC","semantic_summary":"HL.ADDTPC - Add the encoded displacement to the program counter.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.addtpc imm, ->{t, u, Rd}"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["hl.addtpc imm, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","imm32":"Encoded zero supplies numeric zero for the 32-bit immediate value."},"legality":["hl_addtpc_48_2e8e692eea09.RegDst excludes 10; the excluded encoding is reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"imm32","role":"32-bit immediate value"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["HL.ADDTPC - Add the encoded displacement to the program counter.","After decode and legality checks, execute the normative AddToPC ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-ADDTPC","mnemonic":"HL.ADDTPC","summary":"HL.ADDTPC - Add the encoded displacement to the program counter.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_HL_ADDTPC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_HL_ADDTPC(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
// DOC-END: operation
