// PTO-INSTRUCTION: {"assembly":["ssrset SrcL, SSR_ID"],"block":[],"catalog_indices":[442],"catalog_records":[{"asm":"ssrset SrcL, SSR_ID","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x0000103b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"ssrset_32_4dd3b71802c6","length_bits":32,"mnemonic":"SSRSET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterSet","status":"accepted"}],"classification":["sys"],"mnemonic":"SSRSET","summary":"Execute the SSRSET scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SSRSET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SSRSET() => ScalarOperation
begin
    return ScalarOperation_SSRSET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SSRSET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;
// DOC-END: operation
