// PTO-INSTRUCTION: {"assembly":["FEXIT [RegDst0 ~ RegDstn], sp!, uimm"],"block":[],"catalog_indices":[71],"catalog_records":[{"asm":"FEXIT [RegDst0 ~ RegDstn], sp!, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001041","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstBegin","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"DstEnd","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm","pieces":[{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}],"signedness":"unsigned","width":15}],"form_id":"fexit_32_37b663f2a34d","length_bits":32,"mnemonic":"FEXIT","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteFrameExit","semantic_summary":"Atomically validates and commits a frame-template exit state.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"FEXIT","summary":"Atomically validates and commits a frame-template exit state.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_FEXIT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fexit_32_37b663f2a34d);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FEXIT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameExit;
end;
// DOC-END: operation
