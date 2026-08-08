// PTO-INSTRUCTION: {"assembly":["FRET.STK [RegDst0 ~ RegDstn], sp!, uimm"],"block":[],"catalog_indices":[73],"catalog_records":[{"asm":"FRET.STK [RegDst0 ~ RegDstn], sp!, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003041","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstBegin","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"DstEnd","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm","pieces":[{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}],"signedness":"unsigned","width":15}],"form_id":"fret_stk_32_4fe246bd8241","length_bits":32,"mnemonic":"FRET.STK","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteFrameReturnStack","semantic_summary":"Restores a frame and returns through the validated stack target.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"FRET.STK","summary":"Restores a frame and returns through the validated stack target.","surface":"block","id":"PTO-BLOCK-FRET-STK","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_FRET_STK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_stk_32_4fe246bd8241);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FRET_STK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnStack;
end;
// DOC-END: operation
