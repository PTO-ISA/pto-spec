// PTO-INSTRUCTION: {"assembly":["subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}"],"block":[],"catalog_indices":[447],"catalog_records":[{"asm":"subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001025","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"subw_32_3a8d45653c98","length_bits":32,"mnemonic":"SUBW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","status":"accepted","semantic_summary":"SUBW - Compute this mnemonic's 32-bit binary operation and sign-extend the result."}],"classification":["alu"],"mnemonic":"SUBW","summary":"SUBW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.","surface":"scalar","id":"PTO-SCALAR-SUBW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SUBW() => ScalarOperation
begin
    return ScalarOperation_SUBW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SUBW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
// DOC-END: operation
