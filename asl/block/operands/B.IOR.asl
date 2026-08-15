// PTO-INSTRUCTION: {"assembly":["B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>]"],"block":[],"catalog_indices":[7],"catalog_records":[{"asm":"B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>]","complete_bundle_schema":{"encoded_surplus_rule":"RegSrc2, RegDst, and all unconsumed source fields must be zero","evidence":"spec/evidence/bundle-command-totality.json","gpr_logical_order":["scalar QuantParam","scalar LReLUParam"],"omission_default":"R0/zero for each consumed slot","owner":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"},"constraints":[{"field":"RegDst","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x0600707f","match":"0x00000013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"b_ior_32_c3ea71404eb3","length_bits":32,"mnemonic":"B.IOR","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleScalarIO","semantic_summary":"Bind up to three absolute GPR inputs and one absolute GPR output; TLOAD/TSTORE use source zero as GM base and source one as logical row stride.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["Optional once after BSTART and before the block body for every schema that declares GPR inputs or outputs."],"canonical_assembly":["B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>]"],"defaults":["The complete BSTART operation schema determines whether B.IOR is consumed and the number and roles of its GPR inputs and output.","When B.IOR is omitted, every consumed input or output uses its operation-defined default. An explicitly encoded selector zero names the architectural zero GPR and is not omission.","For TLOAD and TSTORE, omission supplies GM base zero and a dense logical row stride equal to the resolved column count; explicit RegSrc1=zero supplies a zero stride.","Matrix postprocess B.IOR slots follow the complete B.FPATR schema: scalar QuantParam then scalar LReLUParam, with omitted consumed slots reading the zero GPR."],"encoding_class":"standalone-encoded","examples":["B.IOR a0, a1, zero, ->zero"],"exceptions":["An out-of-range selector raises Fault_IllegalInstruction before binding state changes.","Standalone, body-phase, or duplicate B.IOR raises Illegal Block Exception before binding state changes.","A nonzero unused field or other operation-schema mismatch raises a block/tile legality fault before operation effects."],"field_contracts":{"RegDst":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"RegSrc2":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","RegSrc0":"Encoded zero names the architectural zero GPR.","RegSrc1":"Encoded zero names the architectural zero GPR.","RegSrc2":"Encoded zero names the architectural zero GPR."},"legality":["B.IOR is legal only after BSTART and before the block body, in any block whose complete schema declares GPR operands; an explicitly all-zero B.IOR is also legal when the schema consumes none.","A block contains at most one B.IOR; a second instruction raises Illegal Block Exception and preserves the first binding.","RegDst and RegSrc0..RegSrc2 accept only absolute GPR selectors 0..23; selectors 24..31 are reserved and reject before effects.","Sources may repeat and may alias RegDst. Any nonzero field not consumed by the selected complete-block schema rejects before block effects.","RegDst remains zero unless the selected complete-block schema explicitly declares a GPR result; current Matrix B.FPATR schemas consume only RegSrc inputs."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"RegSrc0","role":"first absolute GPR source"},{"field":"RegSrc1","role":"second absolute GPR source"},{"field":"RegSrc2","role":"third absolute GPR source"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["Record one explicit B.IOR instruction and its four absolute GPR selectors as pending block-header state; effective arity is derived from the complete operation schema.","Inputs are read according to the selected operation before destination publication; no GPR is modified merely by executing B.IOR."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"field_domains":[{"assigned":[{"meaning":"zero","value":0},{"meaning":"sp","value":1},{"meaning":"a0","value":2},{"meaning":"a1","value":3},{"meaning":"a2","value":4},{"meaning":"a3","value":5},{"meaning":"a4","value":6},{"meaning":"a5","value":7},{"meaning":"a6","value":8},{"meaning":"a7","value":9},{"meaning":"ra","value":10},{"meaning":"s0","value":11},{"meaning":"s1","value":12},{"meaning":"s2","value":13},{"meaning":"s3","value":14},{"meaning":"s4","value":15},{"meaning":"s5","value":16},{"meaning":"s6","value":17},{"meaning":"s7","value":18},{"meaning":"s8","value":19},{"meaning":"x0","value":20},{"meaning":"x1","value":21},{"meaning":"x2","value":22},{"meaning":"x3","value":23}],"id":"PTO-FIELD-BLOCK-GPR-SELECTOR","rejection":"Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.","reserved":[24,25,26,27,28,29,30,31],"role":"Selects one absolute architectural GPR for B.IOR input or output binding.","width":5,"zero_meaning":"Code zero names the architectural zero GPR; it never means an omitted B.IOR field."}],"id":"PTO-BLOCK-B-IOR","mnemonic":"B.IOR","summary":"Bind up to three absolute GPR inputs and one absolute GPR output; TLOAD/TSTORE use source zero as GM base and source one as logical row stride.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-IOR-BINDING-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.IOR MUST bind only absolute GPR selectors 0..23, MUST distinguish an
// omitted instruction from an encoded zero selector, and MUST derive consumed
// fields and omission defaults from the complete selected block schema.
// NDF-END: PTO-B-IOR-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_IOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ior_32_c3ea71404eb3);
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Canonical <gpr> spellings are zero, sp, a0..a7, ra, s0..s8, and x0..x3.
// Relative T/U queue selectors are not legal in any B.IOR field.
// B.IOR binds at most three dense input slots, RegSrc0..RegSrc2, in the
// operation-independent logical order address, scalar0, scalar1, diagonal,
// flag0. Omission is distinct from an encoded zero selector. Consumers own
// raw-value validation before constrained assignment; a second B.IOR faults
// with Fault_BundleControl and preserves the first binding.
// Matrix complete-bundle consumers append optional scalar QuantParam then
// scalar LReLUParam in the same dense RegSrc order. Their omission/default,
// surplus-zero, and raw-carrier policy is owned by the dynamic schema at
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and
// spec/evidence/bundle-command-totality.json.
pure func InstructionContractMatrixPostProcessGPRQuantSlot_B_IOR() => integer
begin
    return 0;
end;

pure func InstructionContractMatrixPostProcessGPRLReLUSlot_B_IOR() => integer
begin
    return 1;
end;

pure func InstructionContractMatrixPostProcessGPRCapacity_B_IOR() => integer
begin
    return 3;
end;

pure func InstructionContractAbsoluteGPRSelectorLegal_B_IOR(
    selector: Reg5Selector) => boolean
begin
    return selector < PTO_ABSOLUTE_GPR_COUNT;
end;

// In TLOAD/TSTORE schemas source zero supplies the GM base and source one
// supplies row stride in logical elements.  Omission is distinct from an
// encoded selector whose current value is zero.
pure func InstructionContractTLSUBaseSource_B_IOR() => integer
begin
    return 0;
end;

pure func InstructionContractTLSURowStrideSource_B_IOR() => integer
begin
    return 1;
end;

readonly func InstructionContractHandler_B_IOR() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleScalarIO;
end;
// DOC-END: operation
