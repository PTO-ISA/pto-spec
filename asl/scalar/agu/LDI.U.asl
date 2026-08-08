// PTO-INSTRUCTION: {"assembly":["ldi.u [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[333],"catalog_records":[{"asm":"ldi.u [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003029","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"ldi_u_32_111bb521a439","length_bits":32,"mnemonic":"LDI.U","semantic_family":"AGU","semantic_group":"LDA/UNSCALED","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"LDI.U","summary":"Execute the LDI.U scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-LDI-U","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LDI_U() => ScalarOperation
begin
    return ScalarOperation_LDI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LDI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
