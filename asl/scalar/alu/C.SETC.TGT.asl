// PTO-INSTRUCTION: {"assembly":["c.setc.tgt srcL"],"block":[],"catalog_indices":[45],"catalog_records":[{"asm":"c.setc.tgt srcL","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x001c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_setc_tgt_16_736be9cada01","length_bits":16,"mnemonic":"C.SETC.TGT","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"SetCommitTarget","status":"accepted","semantic_summary":"C.SETC.TGT - Write the bundle commit target."}],"classification":["alu"],"mnemonic":"C.SETC.TGT","summary":"C.SETC.TGT - Write the bundle commit target.","surface":"scalar","id":"PTO-SCALAR-C-SETC-TGT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_C_SETC_TGT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;
// DOC-END: operation
