// PTO-INSTRUCTION: {"assembly":["hl.ldip.u [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[175],"catalog_records":[{"asm":"hl.ldip.u [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00003029001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_ldip_u_48_6813f4fdce5c","length_bits":48,"mnemonic":"HL.LDIP.U","semantic_family":"AGU","semantic_group":"LDA/PAIR","semantic_handler":"ExecuteScalarLoadPair","status":"accepted","semantic_summary":"HL.LDIP.U - Load a scalar register pair using this mnemonic's address-update form."}],"classification":["agu"],"mnemonic":"HL.LDIP.U","summary":"HL.LDIP.U - Load a scalar register pair using this mnemonic's address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-LDIP-U","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LDIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDIP_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LDIP_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;
// DOC-END: operation
