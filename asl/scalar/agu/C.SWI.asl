// PTO-INSTRUCTION: {"assembly":["c.swi t#1, [srcL, simm]"],"block":[],"catalog_indices":[54],"catalog_records":[{"asm":"c.swi t#1, [srcL, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x002a","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_swi_16_ca6c111163e5","length_bits":16,"mnemonic":"C.SWI","semantic_family":"AGU","semantic_group":"STA/BASE_IMM","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"C.SWI","summary":"Execute the C.SWI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-SWI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SWI() => ScalarOperation
begin
    return ScalarOperation_C_SWI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
