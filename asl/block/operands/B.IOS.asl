// PTO-INSTRUCTION: {"assembly":["B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>"],"block":[],"catalog_indices":[58],"catalog_records":[{"asm":"B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>","constraints":[],"encoding":[{"index":0,"mask":"0xf00871ff","match":"0x00001013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SharedTID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":8}],"signedness":"encoding-defined","width":8},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"TSize","pieces":[{"instruction_lsb":9,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"b_ios_32_4ba5ef98fdaa","length_bits":32,"mnemonic":"B.IOS","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleSharedIO","semantic_summary":"Binds one ordered absolute core-private Shared register S0..S255 with a per-PE source/destination size code and four-PE participation mask.","status":"accepted"}],"classification":["operands"],"mnemonic":"B.IOS","summary":"Binds one ordered absolute core-private Shared register S0..S255 with a per-PE source/destination size code and four-PE participation mask.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_IOS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ios_32_4ba5ef98fdaa);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
// DOC-END: operation
