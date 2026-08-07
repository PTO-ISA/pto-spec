// PTO-INSTRUCTION: {"assembly":["hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[130],"catalog_records":[{"asm":"hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f000f","match":"0x0000204d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"immr","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":10,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"hl_bfi_48_8adfd476aacc","length_bits":48,"mnemonic":"HL.BFI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"InsertBitfield","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.BFI","summary":"Execute the HL.BFI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_BFI() => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_BFI() => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;
// DOC-END: operation
