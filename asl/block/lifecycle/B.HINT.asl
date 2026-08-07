// PTO-INSTRUCTION: {"assembly":["B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}","B.HINT TRACE.{begin, end}"],"block":[],"catalog_indices":[5,6],"catalog_records":[{"asm":"B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}","constraints":[],"encoding":[{"index":0,"mask":"0x00087fff","match":"0x00000033","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"L/UL","pieces":[{"instruction_lsb":16,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"V","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"prefetch_size","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"temp","pieces":[{"instruction_lsb":17,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"b_hint_32_69d942ff1583","length_bits":32,"mnemonic":"B.HINT","semantic_family":"CMD","semantic_group":"Bundle Hint","semantic_handler":"SetBundleHint","semantic_summary":"Records non-functional branch, temperature, prefetch-size, or trace guidance.","status":"accepted"},{"asm":"B.HINT TRACE.{begin, end}","constraints":[],"encoding":[{"index":0,"mask":"0xffff7fff","match":"0x00001033","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"B/E","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"b_hint_32_f7d01d734925","length_bits":32,"mnemonic":"B.HINT","semantic_family":"CMD","semantic_group":"Bundle Hint","semantic_handler":"SetBundleHint","semantic_summary":"Records non-functional branch, temperature, prefetch-size, or trace guidance.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"B.HINT","summary":"Records non-functional branch, temperature, prefetch-size, or trace guidance.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_HINT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_hint_32_69d942ff1583) ||
           (operation == CommandOperation_b_hint_32_f7d01d734925);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_HINT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleHint;
end;
// DOC-END: operation
