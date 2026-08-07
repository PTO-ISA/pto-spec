// PTO-INSTRUCTION: {"assembly":["bxu SrcL, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[30],"catalog_records":[{"asm":"bxu SrcL, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"bxu_32_e9ea9715ba62","length_bits":32,"mnemonic":"BXU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtractBitfield","status":"accepted"}],"classification":["alu"],"mnemonic":"BXU","summary":"Execute the BXU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BXU() => ScalarOperation
begin
    return ScalarOperation_BXU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BXU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;
// DOC-END: operation
