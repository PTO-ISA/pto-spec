// PTO-INSTRUCTION: {"assembly":["c.movi simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[39],"catalog_records":[{"asm":"c.movi simm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x003f","match":"0x0016","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_movi_16_2c84faf1bc72","length_bits":16,"mnemonic":"C.MOVI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MoveScalarValue","status":"accepted"}],"classification":["alu"],"mnemonic":"C.MOVI","summary":"Execute the C.MOVI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_MOVI() => ScalarOperation
begin
    return ScalarOperation_C_MOVI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_MOVI() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;
// DOC-END: operation
