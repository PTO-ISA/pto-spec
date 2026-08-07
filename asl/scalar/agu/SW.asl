// PTO-INSTRUCTION: {"assembly":["sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]"],"block":[],"catalog_indices":[448],"catalog_records":[{"asm":"sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00002049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sw_32_28ad317b1b41","length_bits":32,"mnemonic":"SW","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SW","summary":"Execute the SW scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SW() => ScalarOperation
begin
    return ScalarOperation_SW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
