// PTO-INSTRUCTION: {"assembly":["hl.qmt.{i,e,s,r,ie,is,ir,es,er,ies,ier} SrcL, SrcR, ->{t, u}"],"block":[],"catalog_indices":[84],"catalog_records":[{"asm":"hl.qmt.{i,e,s,r,ie,is,ir,es,er,ies,ier} SrcL, SrcR, ->{t, u}","constraints":[],"encoding":[{"index":0,"mask":"0xe000707fffff","match":"0x0000007d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"e","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"i","pieces":[{"instruction_lsb":44,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"r","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"s","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_qmt_48_eb9e41958045","length_bits":48,"mnemonic":"HL.QMT","semantic_family":"CMD","semantic_group":"General","semantic_handler":"ExecuteQueueMove","semantic_summary":"Moves values between scalar temporary queues according to encoded queue controls.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"HL.QMT","summary":"Moves values between scalar temporary queues according to encoded queue controls.","surface":"block","id":"PTO-BLOCK-HL-QMT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_QMT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qmt_48_eb9e41958045);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_QMT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueueMove;
end;
// DOC-END: operation
