// PTO-INSTRUCTION: {"assembly":["hl.setret imm, ->Ra"],"block":[],"catalog_indices":[275],"catalog_records":[{"asm":"hl.setret imm, ->Ra","constraints":[],"encoding":[{"index":0,"mask":"0x00000fff000f","match":"0x00000507000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"imm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"encoding-defined","width":32}],"form_id":"hl_setret_48_302bb793a800","length_bits":48,"mnemonic":"HL.SETRET","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"SetReturnAddress","status":"accepted","semantic_summary":"HL.SETRET - Write the architectural return address."}],"classification":["bru"],"mnemonic":"HL.SETRET","summary":"HL.SETRET - Write the architectural return address.","surface":"scalar","id":"PTO-SCALAR-HL-SETRET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
// DOC-END: operation
