// PTO-INSTRUCTION: {"assembly":["hl.sdip SrcD, SrcD1, [SrcR, simm]"],"block":[],"catalog_indices":[263],"catalog_records":[{"asm":"hl.sdip SrcD, SrcD1, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00003059001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_sdip_48_6d622cf167ca","length_bits":48,"mnemonic":"HL.SDIP","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","status":"accepted","semantic_summary":"HL.SDIP - Store a scalar register pair using this mnemonic's address-update form."}],"classification":["agu"],"mnemonic":"HL.SDIP","summary":"HL.SDIP - Store a scalar register pair using this mnemonic's address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-SDIP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SDIP() => ScalarOperation
begin
    return ScalarOperation_HL_SDIP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SDIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
// DOC-END: operation
