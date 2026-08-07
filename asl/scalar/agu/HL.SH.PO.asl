// PTO-INSTRUCTION: {"assembly":["hl.sh.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<1], ->{t, u, Rd}"],"block":[],"catalog_indices":[277],"catalog_records":[{"asm":"hl.sh.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<1], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff07ff","match":"0x00001049003e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_sh_po_48_e0b543d5b724","length_bits":48,"mnemonic":"HL.SH.PO","semantic_family":"AGU","semantic_group":"STA/POST_INDEX","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SH.PO","summary":"Execute the HL.SH.PO scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SH_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SH_PO;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SH_PO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
