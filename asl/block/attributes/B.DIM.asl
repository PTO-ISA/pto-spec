// PTO-INSTRUCTION: {"assembly":["B.DIM RegSrc, uimm, ->LB2","B.DIM RegSrc, uimm, ->LB0","B.DIM RegSrc, uimm, ->LB1"],"block":[],"catalog_indices":[2,3,4],"catalog_records":[{"asm":"B.DIM RegSrc, uimm, ->LB2","constraints":[{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002043","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm17","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"unsigned","width":17}],"form_id":"b_dim_32_1caa1aa2944a","length_bits":32,"mnemonic":"B.DIM","semantic_family":"CMD","semantic_group":"Bundle Argument","semantic_handler":"SetBundleDimension","semantic_summary":"Writes zero-extend((GPR[RegSrc] + uimm17)[15:0]) to the selected bundle-local LB register exactly once.","status":"accepted"},{"asm":"B.DIM RegSrc, uimm, ->LB0","constraints":[{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000043","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm17","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"unsigned","width":17}],"form_id":"b_dim_32_27602ab68929","length_bits":32,"mnemonic":"B.DIM","semantic_family":"CMD","semantic_group":"Bundle Argument","semantic_handler":"SetBundleDimension","semantic_summary":"Writes zero-extend((GPR[RegSrc] + uimm17)[15:0]) to the selected bundle-local LB register exactly once.","status":"accepted"},{"asm":"B.DIM RegSrc, uimm, ->LB1","constraints":[{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001043","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm17","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"unsigned","width":17}],"form_id":"b_dim_32_4191099a5f4d","length_bits":32,"mnemonic":"B.DIM","semantic_family":"CMD","semantic_group":"Bundle Argument","semantic_handler":"SetBundleDimension","semantic_summary":"Writes zero-extend((GPR[RegSrc] + uimm17)[15:0]) to the selected bundle-local LB register exactly once.","status":"accepted"}],"classification":["attributes"],"contract":{"block_composition":["Header command after BSTART and before the first body instruction. B.DIM and compressed dimension forms share one write-once presence bit for each of LB0, LB1, and LB2."],"canonical_assembly":["B.DIM RegSrc, uimm17, ->LB0","B.DIM RegSrc, uimm17, ->LB1","B.DIM RegSrc, uimm17, ->LB2"],"defaults":["The selected form fixes LB0, LB1, or LB2; RegSrc and uimm17 are both encoded and zero remains an explicit value."],"encoding_class":"standalone-encoded","examples":["B.DIM a0, 16, ->LB0","B.DIM zero, 0, ->LB2"],"exceptions":["RegSrc codes 24 through 31 raise Fault_IllegalInstruction before reading a queue or changing bundle state.","A write outside an active block header or a second write to the same LB raises Fault_BundleControl before changing the first value."],"field_contracts":{},"field_zero_meanings":{"RegSrc":"Encoded zero names the architectural zero GPR.","uimm17":"Encoded zero supplies a zero displacement or zero immediate value."},"legality":["b_dim_32_1caa1aa2944a.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.","b_dim_32_27602ab68929.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.","b_dim_32_4191099a5f4d.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved."],"memory_effects":["none"],"operands":[{"field":"RegSrc","role":"absolute GPR source 0 through 23"},{"field":"uimm17","role":"unsigned addend before low-16-bit truncation"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["Computes zero-extend((GPR[RegSrc] + zero-extend(uimm17))[15:0]) and writes the selected LB0, LB1, or LB2 register.","LB meanings are selected by the completed operation schema; B.DIM itself assigns no universal row, column, M, N, or K role.","Each LB may be written at most once per block across B.DIM and compressed dimension forms."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-B-DIM","mnemonic":"B.DIM","summary":"Writes one selected bundle-local LB register from an absolute GPR plus immediate, truncated to 16 bits.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-DIM-WRITE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.DIM MUST read only absolute GPR codes 0..23, MUST write the low sixteen
// bits of GPR plus unsigned uimm17, and MUST write each selected LB at most
// once across all full and compressed dimension forms in one block.
// NDF-END: PTO-B-DIM-WRITE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_DIM(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_dim_32_1caa1aa2944a) ||
           (operation == CommandOperation_b_dim_32_27602ab68929) ||
           (operation == CommandOperation_b_dim_32_4191099a5f4d);
end;
// DOC-END: decode
// DOC-BEGIN: operation
type BundleDimensionRegister of enumeration {
    BundleDimension_LB0,
    BundleDimension_LB1,
    BundleDimension_LB2
};

pure func BundleDimensionIndexOfRegister(reg: BundleDimensionRegister)
    => BundleDimensionIndex
begin
    case reg of
        when BundleDimension_LB0 => return 0;
        when BundleDimension_LB1 => return 1;
        when BundleDimension_LB2 => return 2;
    end;
end;

readonly func InstructionContractHandler_B_DIM() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
// DOC-END: operation
