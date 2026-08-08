// PTO-INSTRUCTION: {"assembly":["B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}"],"block":[],"catalog_indices":[0],"catalog_records":[{"asm":"B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}","constraints":[],"encoding":[{"index":0,"mask":"0xfbf07fff","match":"0x00000023","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DR","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"trap","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":18,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"atom","pieces":[{"instruction_lsb":17,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"aq","pieces":[{"instruction_lsb":16,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"b_catr_32_e90bd52fa480","length_bits":32,"mnemonic":"B.CATR","semantic_family":"CMD","semantic_group":"Bundle Control Attribute","semantic_handler":"SetBundleControlAttributes","semantic_summary":"Latches bundle control, trap, atomic, ordering, and address-class attributes.","status":"accepted"}],"classification":["attributes"],"mnemonic":"B.CATR","summary":"Latches bundle control, trap, atomic, ordering, and address-class attributes.","surface":"block","id":"PTO-BLOCK-B-CATR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_CATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_catr_32_e90bd52fa480);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_CATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleControlAttributes;
end;
// DOC-END: operation
