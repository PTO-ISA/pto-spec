// PTO-INSTRUCTION: {"assembly":["bxs SrcL, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[29],"catalog_records":[{"asm":"bxs SrcL, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"bxs_32_b1bb003c1703","length_bits":32,"mnemonic":"BXS","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtractBitfield","status":"accepted"}],"classification":["alu"],"mnemonic":"BXS","summary":"Execute the BXS scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-BXS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BXS() => ScalarOperation
begin
    return ScalarOperation_BXS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BXS() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;
// DOC-END: operation
