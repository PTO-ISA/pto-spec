// PTO-INSTRUCTION: {"assembly":["slliw SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[431],"catalog_records":[{"asm":"slliw SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00007035","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"slliw_32_c6bf463b97ae","length_bits":32,"mnemonic":"SLLIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","status":"accepted"}],"classification":["alu"],"mnemonic":"SLLIW","summary":"Execute the SLLIW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SLLIW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SLLIW() => ScalarOperation
begin
    return ScalarOperation_SLLIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SLLIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
// DOC-END: operation
