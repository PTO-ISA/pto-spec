// PTO-INSTRUCTION: {"assembly":["addtpc simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[5],"catalog_records":[{"asm":"addtpc simm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000007","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"addtpc_32_e5aa0f0abca3","length_bits":32,"mnemonic":"ADDTPC","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"AddToPC","status":"accepted"}],"classification":["bru"],"mnemonic":"ADDTPC","summary":"Execute the ADDTPC scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-ADDTPC","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
