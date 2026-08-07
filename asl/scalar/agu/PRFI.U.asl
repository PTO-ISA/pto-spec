// PTO-INSTRUCTION: {"assembly":["prfi.u [SrcL, simm]"],"block":[],"catalog_indices":[379],"catalog_records":[{"asm":"prfi.u [SrcL, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007029","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"prfi_u_32_167b42882547","length_bits":32,"mnemonic":"PRFI.U","semantic_family":"AGU","semantic_group":"LDA/UNSCALED","semantic_handler":"ScalarPrefetch","status":"accepted"}],"classification":["agu"],"mnemonic":"PRFI.U","summary":"Execute the PRFI.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_PRFI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_PRFI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
// DOC-END: operation
