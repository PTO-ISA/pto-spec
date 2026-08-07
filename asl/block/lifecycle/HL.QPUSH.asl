// PTO-INSTRUCTION: {"assembly":["hl.qpush.{h,e,r,he,hr,er,her} SrcL, SrcR, ->{t, u}"],"block":[],"catalog_indices":[86],"catalog_records":[{"asm":"hl.qpush.{h,e,r,he,hr,er,her} SrcL, SrcR, ->{t, u}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707fffff","match":"0x0000107d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"e","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"h","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"r","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_qpush_48_3eab8e05d61a","length_bits":48,"mnemonic":"HL.QPUSH","semantic_family":"CMD","semantic_group":"General","semantic_handler":"ExecuteQueuePush","semantic_summary":"Pushes the encoded scalar values to the selected temporary queue.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"HL.QPUSH","summary":"Pushes the encoded scalar values to the selected temporary queue.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_QPUSH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpush_48_3eab8e05d61a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_QPUSH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePush;
end;
// DOC-END: operation
