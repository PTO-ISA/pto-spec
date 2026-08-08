// PTO-INSTRUCTION: {"assembly":["bwi SrcL"],"block":[],"catalog_indices":[27],"catalog_records":[{"asm":"bwi SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0020002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bwi_32_d9a0905cb31b","length_bits":32,"mnemonic":"BWI","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","status":"accepted"}],"classification":["sys"],"mnemonic":"BWI","summary":"Execute the BWI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-BWI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BWI() => ScalarOperation
begin
    return ScalarOperation_BWI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
// DOC-END: operation
