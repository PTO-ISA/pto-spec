// PTO-INSTRUCTION: {"assembly":["hl.swi SrcD, [SrcR, simm]"],"block":[],"catalog_indices":[300],"catalog_records":[{"asm":"hl.swi SrcD, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00002059000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm22","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}],"signedness":"signed","width":22}],"form_id":"hl_swi_48_13deb2849df5","length_bits":48,"mnemonic":"HL.SWI","semantic_family":"AGU","semantic_group":"STA/LONG","semantic_handler":"ExecuteScalarStore","status":"accepted","semantic_summary":"HL.SWI - Store scalar data using this mnemonic's width and address-update form."}],"classification":["agu"],"mnemonic":"HL.SWI","summary":"HL.SWI - Store scalar data using this mnemonic's width and address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-SWI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SWI() => ScalarOperation
begin
    return ScalarOperation_HL_SWI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
