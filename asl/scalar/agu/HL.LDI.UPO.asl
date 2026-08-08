// PTO-INSTRUCTION: {"assembly":["hl.ldi.upo [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[172],"catalog_records":[{"asm":"hl.ldi.upo [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00003029003e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_ldi_upo_48_5126b735cfe8","length_bits":48,"mnemonic":"HL.LDI.UPO","semantic_family":"AGU","semantic_group":"LDA/POST_INDEX","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LDI.UPO","summary":"Execute the HL.LDI.UPO scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-LDI-UPO","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LDI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_UPO;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LDI_UPO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
