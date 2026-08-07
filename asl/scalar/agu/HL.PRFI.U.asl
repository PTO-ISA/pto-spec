// PTO-INSTRUCTION: {"assembly":["hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]"],"block":[],"catalog_indices":[238],"catalog_records":[{"asm":"hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff003f","match":"0x00007029000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"model","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_prfi_u_48_be73891e376e","length_bits":48,"mnemonic":"HL.PRFI.U","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ScalarPrefetch","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.PRFI.U","summary":"Execute the HL.PRFI.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_PRFI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
// DOC-END: operation
