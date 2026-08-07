// PTO-INSTRUCTION: {"assembly":["hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"block":[],"catalog_indices":[290],"catalog_records":[{"asm":"hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}>]","constraints":[],"encoding":[{"index":0,"mask":"0x00007ffff83f","match":"0x00005049001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_shp_u_48_232b2200b7b9","length_bits":48,"mnemonic":"HL.SHP.U","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SHP.U","summary":"Execute the HL.SHP.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SHP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SHP_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SHP_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
// DOC-END: operation
