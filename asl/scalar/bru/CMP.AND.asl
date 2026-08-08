// PTO-INSTRUCTION: {"assembly":["cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}"],"block":[],"catalog_indices":[63],"catalog_records":[{"asm":"cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x00002045","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"cmp_and_32_036813a12ae8","length_bits":32,"mnemonic":"CMP.AND","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"CMP.AND","summary":"Execute the CMP.AND scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-CMP-AND","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_AND() => ScalarOperation
begin
    return ScalarOperation_CMP_AND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
// DOC-END: operation
