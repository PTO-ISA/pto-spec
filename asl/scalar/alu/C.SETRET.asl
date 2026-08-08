// PTO-INSTRUCTION: {"assembly":["c.setret uimm, - >Ra"],"block":[],"catalog_indices":[46],"catalog_records":[{"asm":"c.setret uimm, - >Ra","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x5016","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"uimm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"c_setret_16_335651ef6c27","length_bits":16,"mnemonic":"C.SETRET","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"SetReturnAddress","status":"accepted"}],"classification":["alu"],"mnemonic":"C.SETRET","summary":"Execute the C.SETRET scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-SETRET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETRET() => ScalarOperation
begin
    return ScalarOperation_C_SETRET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
// DOC-END: operation
