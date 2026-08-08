// PTO-INSTRUCTION: {"assembly":["C.B.DIMI imm, ->{LB0, LB1, LB2}"],"block":[],"catalog_indices":[59],"catalog_records":[{"asm":"C.B.DIMI imm, ->{LB0, LB1, LB2}","constraints":[{"field":"LoopNest","operator":"not-equal","value":3}],"encoding":[{"index":0,"mask":"0x003f","match":"0x003c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"LoopNest","pieces":[{"instruction_lsb":14,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"imm8","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":8}],"signedness":"encoding-defined","width":8}],"form_id":"c_b_dimi_16_3f1b113c76ce","length_bits":16,"mnemonic":"C.B.DIMI","semantic_family":"CMD","semantic_group":"Bundle Dimension","semantic_handler":"SetBundleDimension","semantic_summary":"Writes one of the three bundle-local dimension registers.","status":"accepted"}],"classification":["attributes"],"mnemonic":"C.B.DIMI","summary":"Writes one of the three bundle-local dimension registers.","surface":"block","id":"PTO-BLOCK-C-B-DIMI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_B_DIMI(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_b_dimi_16_3f1b113c76ce);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_B_DIMI() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
// DOC-END: operation
