// PTO-INSTRUCTION: {"assembly":["setret uimm, ->Ra"],"block":[],"catalog_indices":[423],"catalog_records":[{"asm":"setret uimm, ->Ra","constraints":[],"encoding":[{"index":0,"mask":"0x00000fff","match":"0x00000507","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"setret_32_72003dcf3b59","length_bits":32,"mnemonic":"SETRET","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"SetReturnAddress","status":"accepted"}],"classification":["bru"],"mnemonic":"SETRET","summary":"Execute the SETRET scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SETRET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETRET() => ScalarOperation
begin
    return ScalarOperation_SETRET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
// DOC-END: operation
