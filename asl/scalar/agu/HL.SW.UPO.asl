// PTO-INSTRUCTION: {"assembly":["hl.sw.upo SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}"],"block":[],"catalog_indices":[298],"catalog_records":[{"asm":"hl.sw.upo SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff07ff","match":"0x00006049003e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_sw_upo_48_59be7b468f8a","length_bits":48,"mnemonic":"HL.SW.UPO","semantic_family":"AGU","semantic_group":"STA/POST_INDEX","semantic_handler":"ExecuteScalarStore","status":"accepted","semantic_summary":"HL.SW.UPO - Store scalar data using this mnemonic's width and address-update form."}],"classification":["agu"],"mnemonic":"HL.SW.UPO","summary":"HL.SW.UPO - Store scalar data using this mnemonic's width and address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-SW-UPO","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SW_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SW_UPO;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SW_UPO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
