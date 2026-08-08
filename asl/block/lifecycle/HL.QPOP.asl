// PTO-INSTRUCTION: {"assembly":["hl.qpop.{e,r,er} SrcL, ->Dst0, Dst1"],"block":[],"catalog_indices":[85],"catalog_records":[{"asm":"hl.qpop.{e,r,er} SrcL, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f07ff","match":"0x0000207d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"e","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"r","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_qpop_48_a2c57f5bc27b","length_bits":48,"mnemonic":"HL.QPOP","semantic_family":"CMD","semantic_group":"General","semantic_handler":"ExecuteQueuePop","semantic_summary":"Pops selected scalar queue values into encoded destinations.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"HL.QPOP","summary":"Pops selected scalar queue values into encoded destinations.","surface":"block","id":"PTO-BLOCK-HL-QPOP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_QPOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpop_48_a2c57f5bc27b);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_QPOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePop;
end;
// DOC-END: operation
