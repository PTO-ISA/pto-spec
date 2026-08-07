// PTO-INSTRUCTION: {"assembly":["hl.sdp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<3]"],"block":[],"catalog_indices":[265],"catalog_records":[{"asm":"hl.sdp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<3]","constraints":[],"encoding":[{"index":0,"mask":"0x00007ffff83f","match":"0x00003049001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_sdp_48_5884c49a7e55","length_bits":48,"mnemonic":"HL.SDP","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SDP","summary":"Execute the HL.SDP scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SDP() => ScalarOperation
begin
    return ScalarOperation_HL_SDP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SDP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
// DOC-END: operation
