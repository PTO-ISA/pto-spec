// PTO-INSTRUCTION: {"assembly":["hl.swp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<2]"],"block":[],"catalog_indices":[308],"catalog_records":[{"asm":"hl.swp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}><<2]","constraints":[],"encoding":[{"index":0,"mask":"0x00007ffff83f","match":"0x00002049001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_swp_48_d0efe96e09f0","length_bits":48,"mnemonic":"HL.SWP","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SWP","summary":"Execute the HL.SWP scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-SWP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SWP() => ScalarOperation
begin
    return ScalarOperation_HL_SWP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SWP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
// DOC-END: operation
