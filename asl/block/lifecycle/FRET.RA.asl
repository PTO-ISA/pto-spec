// PTO-INSTRUCTION: {"assembly":["FRET.RA [RegDst0 ~ RegDstn], sp!, uimm"],"block":[],"catalog_indices":[72],"catalog_records":[{"asm":"FRET.RA [RegDst0 ~ RegDstn], sp!, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002041","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstBegin","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"DstEnd","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm","pieces":[{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}],"signedness":"unsigned","width":15}],"form_id":"fret_ra_32_659c886221c1","length_bits":32,"mnemonic":"FRET.RA","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteFrameReturnAddress","semantic_summary":"Restores a frame and returns through the retained return-address target.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"FRET.RA","summary":"Restores a frame and returns through the retained return-address target.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_FRET_RA(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_ra_32_659c886221c1);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FRET_RA() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnAddress;
end;
// DOC-END: operation
