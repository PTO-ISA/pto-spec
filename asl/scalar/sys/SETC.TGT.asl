// PTO-INSTRUCTION: {"assembly":["setc.tgt SrcL"],"block":[],"catalog_indices":[422],"catalog_records":[{"asm":"setc.tgt SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000403b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"setc_tgt_32_c02656d3a2b8","length_bits":32,"mnemonic":"SETC.TGT","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SetCommitTarget","status":"accepted"}],"classification":["sys"],"mnemonic":"SETC.TGT","summary":"Execute the SETC.TGT scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SETC-TGT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_SETC_TGT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;
// DOC-END: operation
