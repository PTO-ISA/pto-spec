// PTO-INSTRUCTION: {"assembly":["hl.lb.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"block":[],"catalog_indices":[151],"catalog_records":[{"asm":"hl.lb.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x00000009002e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_lb_pr_48_cf73675cad50","length_bits":48,"mnemonic":"HL.LB.PR","semantic_family":"AGU","semantic_group":"LDA/PRE_INDEX","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"HL.LB.PR - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"HL.LB.PR","summary":"HL.LB.PR - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-LB-PR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LB_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LB_PR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
