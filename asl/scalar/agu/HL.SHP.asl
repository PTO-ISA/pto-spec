// PTO-INSTRUCTION: {"assembly":["hl.shp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<1]"],"block":[],"catalog_indices":[289],"catalog_records":[{"asm":"hl.shp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<1]","constraints":[],"encoding":[{"index":0,"mask":"0x00007ffff83f","match":"0x00001049001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_shp_48_ccc507e71a27","length_bits":48,"mnemonic":"HL.SHP","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","status":"accepted","semantic_summary":"HL.SHP - Store a scalar register pair using this mnemonic's address-update form."}],"classification":["agu"],"mnemonic":"HL.SHP","summary":"HL.SHP - Store a scalar register pair using this mnemonic's address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-SHP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SHP() => ScalarOperation
begin
    return ScalarOperation_HL_SHP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SHP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
// DOC-END: operation
