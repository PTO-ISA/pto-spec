// PTO-INSTRUCTION: {"assembly":["setc.gei SrcL, simm"],"block":[],"catalog_indices":[411],"catalog_records":[{"asm":"setc.gei SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00005075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_gei_32_c3f4fdc4adcc","length_bits":32,"mnemonic":"SETC.GEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.GEI","summary":"Execute the SETC.GEI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SETC-GEI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_GEI() => ScalarOperation
begin
    return ScalarOperation_SETC_GEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
