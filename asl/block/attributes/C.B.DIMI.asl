// PTO-INSTRUCTION: {"assembly":["C.B.DIMI imm8, ->LB0","C.B.DIMI imm8, ->LB1","C.B.DIMI imm8, ->LB2"],"block":[],"catalog_indices":[53],"catalog_records":[{"asm":"C.B.DIMI imm, ->{LB0, LB1, LB2}","constraints":[{"field":"LoopNest","operator":"not-equal","value":3}],"encoding":[{"index":0,"mask":"0x003f","match":"0x003c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"LoopNest","pieces":[{"instruction_lsb":14,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"imm8","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":8}],"signedness":"encoding-defined","width":8}],"form_id":"c_b_dimi_16_3f1b113c76ce","length_bits":16,"mnemonic":"C.B.DIMI","semantic_family":"CMD","semantic_group":"Bundle Dimension","semantic_handler":"SetBundleDimension","semantic_summary":"Zero-extends imm8 and writes one selected bundle-local LB exactly once.","status":"accepted"}],"classification":["attributes"],"contract":{"block_composition":["Header command after BSTART and before the first body instruction. C.B.DIMI and B.DIM share one write-once presence bit for each of LB0, LB1, and LB2."],"canonical_assembly":["C.B.DIMI imm8, ->LB0","C.B.DIMI imm8, ->LB1","C.B.DIMI imm8, ->LB2"],"defaults":["LoopNest 0, 1, and 2 select LB0, LB1, and LB2. imm8 is always present; encoded zero writes numeric zero and is not omission."],"encoding_class":"standalone-encoded","examples":["C.B.DIMI 0, ->LB0","C.B.DIMI 255, ->LB2"],"exceptions":["LoopNest code 3 raises Fault_IllegalInstruction before changing TPC or bundle state.","Execution outside an active block header or a second write to the same LB across C.B.DIMI and B.DIM raises Fault_BundleControl before changing the first value."],"field_contracts":{},"field_zero_meanings":{"LoopNest":"Code zero selects LB0.","imm8":"Encoded zero writes numeric zero to the selected LB."},"legality":["LoopNest codes 0..2 are assigned to LB0..LB2; code 3 is reserved.","imm8 accepts every unsigned value 0..255 and is zero-extended to the bundle dimension word.","Each selected LB is write-once for one block across full and compressed dimension commands."],"memory_effects":["none"],"operands":[{"field":"LoopNest","role":"encoded LB0, LB1, or LB2 selector"},{"field":"imm8","role":"unsigned eight-bit bundle-local dimension value"}],"ordering":["Placement and duplicate checks precede the LB update. A successful update sets the presence bit and value together, then command dispatch advances TPC by two bytes."],"standalone_opcode":true,"state_effects":["Write ZeroExtend(imm8) to the selected raw LB and set its presence bit.","LB meaning is selected by the completed operation schema; C.B.DIMI assigns no universal row, column, M, N, or K role."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS"],"id":"PTO-BLOCK-C-B-DIMI","mnemonic":"C.B.DIMI","summary":"Writes one selected bundle-local LB from a zero-extended eight-bit immediate exactly once.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_B_DIMI(
    operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_c_b_dimi_16_3f1b113c76ce;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDimension_C_B_DIMI(
    loop_nest: bits(2))
    => BundleDimensionIndex
begin
    assert loop_nest != '11';
    return UInt(loop_nest) as BundleDimensionIndex;
end;

pure func InstructionContractValue_C_B_DIMI(
    immediate: bits(8))
    => Word
begin
    return ZeroExtend{PTO_XLEN}(immediate);
end;

readonly func InstructionContractHandler_C_B_DIMI()
    => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
// DOC-END: operation
