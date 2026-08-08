// PTO-INSTRUCTION: {"assembly":["hl.addtpc imm, ->{t, u, Rd}"],"block":[],"catalog_indices":[127],"catalog_records":[{"asm":"hl.addtpc imm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x00000007000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"encoding-defined","width":32}],"form_id":"hl_addtpc_48_2e8e692eea09","length_bits":48,"mnemonic":"HL.ADDTPC","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"AddToPC","status":"accepted","semantic_summary":"HL.ADDTPC - Add the encoded displacement to the program counter."}],"classification":["bru"],"mnemonic":"HL.ADDTPC","summary":"HL.ADDTPC - Add the encoded displacement to the program counter.","surface":"scalar","id":"PTO-SCALAR-HL-ADDTPC","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
// DOC-END: operation
