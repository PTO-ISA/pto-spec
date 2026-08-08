// PTO-INSTRUCTION: {"assembly":["B.DIM RegSrc, uimm, ->LB2","B.DIM RegSrc, uimm, ->LB0","B.DIM RegSrc, uimm, ->LB1"],"block":[],"catalog_indices":[2,3,4],"catalog_records":[{"asm":"B.DIM RegSrc, uimm, ->LB2","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002043","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm17","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"unsigned","width":17}],"form_id":"b_dim_32_1caa1aa2944a","length_bits":32,"mnemonic":"B.DIM","semantic_family":"CMD","semantic_group":"Bundle Argument","semantic_handler":"SetBundleDimension","semantic_summary":"Writes one of the three bundle-local dimension registers.","status":"accepted"},{"asm":"B.DIM RegSrc, uimm, ->LB0","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000043","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm17","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"unsigned","width":17}],"form_id":"b_dim_32_27602ab68929","length_bits":32,"mnemonic":"B.DIM","semantic_family":"CMD","semantic_group":"Bundle Argument","semantic_handler":"SetBundleDimension","semantic_summary":"Writes one of the three bundle-local dimension registers.","status":"accepted"},{"asm":"B.DIM RegSrc, uimm, ->LB1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001043","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm17","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"unsigned","width":17}],"form_id":"b_dim_32_4191099a5f4d","length_bits":32,"mnemonic":"B.DIM","semantic_family":"CMD","semantic_group":"Bundle Argument","semantic_handler":"SetBundleDimension","semantic_summary":"Writes one of the three bundle-local dimension registers.","status":"accepted"}],"classification":["attributes"],"mnemonic":"B.DIM","summary":"Writes one of the three bundle-local dimension registers.","surface":"block","id":"PTO-BLOCK-B-DIM","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_DIM(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_dim_32_1caa1aa2944a) ||
           (operation == CommandOperation_b_dim_32_27602ab68929) ||
           (operation == CommandOperation_b_dim_32_4191099a5f4d);
end;
// DOC-END: decode
// DOC-BEGIN: operation
type BundleDimensionRole of enumeration {
    BundleDimension_ValidColumns,
    BundleDimension_ValidRows,
    BundleDimension_PhysicalColumns
};

pure func BundleDimensionIndexOfRole(role: BundleDimensionRole)
    => BundleDimensionIndex
begin
    case role of
        when BundleDimension_ValidColumns => return 0;
        when BundleDimension_ValidRows => return 1;
        when BundleDimension_PhysicalColumns => return 2;
    end;
end;

readonly func InstructionContractHandler_B_DIM() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
// DOC-END: operation
