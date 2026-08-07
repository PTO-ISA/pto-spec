// PTO-INSTRUCTION: {"assembly":["hl.lwip [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[213],"catalog_records":[{"asm":"hl.lwip [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00002019001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_lwip_48_e459297b8b7c","length_bits":48,"mnemonic":"HL.LWIP","semantic_family":"AGU","semantic_group":"LDA/PAIR","semantic_handler":"ExecuteScalarLoadPair","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LWIP","summary":"Execute the HL.LWIP scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LWIP() => ScalarOperation
begin
    return ScalarOperation_HL_LWIP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LWIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;
// DOC-END: operation
