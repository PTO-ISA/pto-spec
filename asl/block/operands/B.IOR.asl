// PTO-INSTRUCTION: {"assembly":"B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>][, ExecMaskPresent]","block":[],"catalog_indices":[7],"catalog_records":[{"asm":"B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>][, ExecMaskPresent]","complete_bundle_schema":{"encoded_surplus_rule":"RegSrc2, RegDst, and all unconsumed source fields must be zero","evidence":"spec/evidence/bundle-command-totality.json","gpr_logical_order":["scalar QuantParam","scalar LReLUParam"],"omission_default":"R0/zero for each consumed slot","owner":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","execution_mask_order":"ExecutionMask GPR word(s) follow all operation-owned GPR inputs and ExecMaskPresent is set only on the final binding record."},"constraints":[{"field":"RegDst","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"ExecMaskPresent","operator":"one-of","values":[0,1]}],"encoding":[{"index":0,"mask":"0x0200707f","match":"0x00000013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"ExecMaskPresent","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"b_ior_32_c3ea71404eb3","length_bits":32,"mnemonic":"B.IOR","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleScalarIO","semantic_summary":"Bind up to three absolute GPR inputs and one absolute GPR output; ExecMaskPresent marks final-record GPR ExecutionMask words.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["One B.IOR may appear after BSTART and before the block body when the complete schema declares GPR operands. Eligible Local CUBE ExecutionMask forms may use one or two immediately contiguous records; TGPR2T and TIMG2COL retain their separately owned two-record forms."],"canonical_assembly":["B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>][, ExecMaskPresent]"],"defaults":["The complete BSTART operation schema determines whether B.IOR is consumed and the number and roles of its GPR inputs and output.","When B.IOR is omitted, every consumed input or output uses its operation-defined default. An explicitly encoded selector zero names the architectural zero GPR and is not omission.","For TLOAD and TSTORE, omission supplies GM base zero and a dense byte row stride derived from the resolved column count and DataType; explicit RegSrc1=zero supplies a zero stride.","All indexed TLSU forms require explicit B.IOR with RegSrc0 as the GM base address; RegSrc1, RegSrc2, and RegDst encode zero.","Matrix postprocess B.IOR slots follow the complete B.FPATR schema: scalar QuantParam then scalar LReLUParam, with omitted consumed slots reading the zero GPR."],"encoding_class":"standalone-encoded","examples":["B.IOR a0, a1, zero, ->zero","B.IOR zero, ExecMaskPresent"],"exceptions":["A nonzero unused field or other operation-schema mismatch raises a block/tile legality fault before operation effects.","An out-of-range selector raises Fault_IllegalInstruction before binding state changes. Standalone or body-phase B.IOR raises Illegal Block Exception before binding state changes. Duplicate, noncontiguous, third, misplaced, or schema-inapplicable records and a non-final or inapplicable ExecMaskPresent flag raise Fault_BundleControl or Fault_TileLegality before effects."],"field_contracts":{"RegDst":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"RegSrc2":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","RegSrc0":"Encoded zero names the architectural zero GPR.","RegSrc1":"Encoded zero names the architectural zero GPR.","RegSrc2":"Encoded zero names the architectural zero GPR.","ExecMaskPresent":"No GPR ExecutionMask carrier is bound by this record."},"legality":["B.IOR is legal only after BSTART and before the block body when the complete selected schema declares GPR operands; an explicitly encoded zero selector names GPR0 and is not omission.","RegDst and RegSrc0..RegSrc2 accept only absolute GPR selectors 0..23; selectors 24..31 are reserved and reject before effects.","Sources may repeat and may alias RegDst where the selected complete schema permits a destination. Any nonzero unconsumed field rejects before block effects.","Indexed TLSU consumes RegSrc0 as BaseGPR. RegSrc1, RegSrc2, and RegDst must be zero before memory or destination effects.","Every ordinary block accepts at most one B.IOR. TGPR2T and TIMG2COL retain their exact two-record exceptions. An eligible Local CUBE ExecutionMask GPR form appends one or two words after all operation-owned GPR inputs and may use one or two contiguous records, in dense source order, for up to six GPR inputs. Any GPR destination is allowed only in the first record; the second record is source-only.","ExecMaskPresent is one only on the final contiguous B.IOR record when a GPR ExecutionMask is bound. Earlier records, unpredicated forms, and Predicate-Tile forms require it to be zero. Selector GPR0 is legal and is distinguished from an unused zero selector by the final-record flag and exact schema arity."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"RegSrc0","role":"first absolute GPR source"},{"field":"RegSrc1","role":"second absolute GPR source"},{"field":"RegSrc2","role":"third absolute GPR source"},{"field":"ExecMaskPresent","role":"marks that the final B.IOR record supplies the GPR ExecutionMask word(s) declared by the selected complete schema"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["Record the schema-permitted B.IOR selector state: one record for ordinary consumers or up to two immediately contiguous records for TGPR2T, TIMG2COL, or eligible Local CUBE ExecutionMask forms. Effective arity, roles, and ExecMaskPresent applicability derive from the complete operation schema.","Inputs are read according to the selected operation before destination publication; executing B.IOR itself modifies no GPR."],"summary":"Bind up to three absolute GPR inputs and one absolute GPR output per record; ExecMaskPresent marks final-record GPR ExecutionMask words."},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"field_domains":[{"assigned":[{"meaning":"zero","value":0},{"meaning":"sp","value":1},{"meaning":"a0","value":2},{"meaning":"a1","value":3},{"meaning":"a2","value":4},{"meaning":"a3","value":5},{"meaning":"a4","value":6},{"meaning":"a5","value":7},{"meaning":"a6","value":8},{"meaning":"a7","value":9},{"meaning":"ra","value":10},{"meaning":"s0","value":11},{"meaning":"s1","value":12},{"meaning":"s2","value":13},{"meaning":"s3","value":14},{"meaning":"s4","value":15},{"meaning":"s5","value":16},{"meaning":"s6","value":17},{"meaning":"s7","value":18},{"meaning":"s8","value":19},{"meaning":"x0","value":20},{"meaning":"x1","value":21},{"meaning":"x2","value":22},{"meaning":"x3","value":23}],"id":"PTO-FIELD-BLOCK-GPR-SELECTOR","rejection":"Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.","reserved":[24,25,26,27,28,29,30,31],"role":"Selects one absolute architectural GPR for B.IOR input or output binding.","width":5,"zero_meaning":"Code zero names the architectural zero GPR; it never means an omitted B.IOR field."}],"id":"PTO-BLOCK-B-IOR","mnemonic":"B.IOR","summary":"Bind up to three absolute GPR inputs and one absolute GPR output per record; ExecMaskPresent marks final-record GPR ExecutionMask words.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-IOR-BINDING-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.IOR MUST bind only absolute GPR selectors 0..23, MUST distinguish an
// omitted instruction from an encoded zero selector, and MUST derive consumed
// fields and omission defaults from the complete selected block schema. For
// TGPR2T and eligible Local CUBE ExecutionMask forms are the complete-schema
// exceptions to the ordinary one-record rule. TGPR2T consumes exactly two
// contiguous source-only records with source arity 3+1. An eligible
// ExecutionMask GPR carrier appends one or two source words after all
// operation-owned GPR inputs and may consume at most two contiguous records,
// in dense source order, for up to six absolute GPR inputs. B.IOR[26] is
// ExecMaskPresent and MUST be one only on the final record that supplies the
// GPR mask word(s); B.IOR[25] remains fixed zero. Earlier records,
// unpredicated forms, and Predicate-Tile forms have ExecMaskPresent=0. The
// second record is source-only; both words, when present, form one carrier.
// A complete schema rejects every surplus, misplaced, or inapplicable record
// before effects. PredInv and Zero are B.DATR controls, never B.IOR fields.
// Indexed TLSU consumers MUST bind RegSrc0 as the GM base and MUST leave
// RegSrc1, RegSrc2, and RegDst zero before architectural effects.
// NDF-END: PTO-B-IOR-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_IOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ior_32_c3ea71404eb3);
end;
// DOC-END: decode
// DOC-BEGIN: operation
// B.IOR's complete selected schema is authoritative for record count, source
// and destination role, omitted fields, and surplus rejection. TGPR2T uses
// exactly two contiguous source-only records with source arity 3+1. Eligible
// Local CUBE ExecutionMask GPR forms append one or two source words after all
// operation-owned GPR inputs and may use at most two contiguous records; the
// second is source-only, and the two words (when required) are one carrier.
// A third record, a misplaced record, a non-final presence flag, or any
// nonzero unconsumed selector is illegal. ExecMaskPresent is B.IOR[26];
// B.IOR[25] remains fixed zero. PredInv and Zero belong to B.DATR and are
// not encoded by B.IOR.
// All four selectors name complete 64-bit architectural GPRs in GPR0..GPR23.
// Canonical <gpr> spellings are zero, sp, a0..a7, ra, s0..s8, and x0..x3.
// Relative T/U queue selectors are not legal in any B.IOR field.
// Each B.IOR record binds up to three dense input slots, RegSrc0..RegSrc2.
// For eligible Local CUBE ExecutionMask forms, complete schemas concatenate
// up to two records in operation-owned order followed by mask word(s).
// Omission is distinct from an encoded zero selector. Consumers own raw-value
// validation before constrained assignment; a second B.IOR is accepted only
// by TGPR2T, TIMG2COL, or an eligible ExecutionMask GPR schema.
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
// supplies row stride in bytes.  Omission is distinct from an
// encoded selector whose current value is zero.
// Indexed TLSU schemas require an explicit B.IOR: source zero supplies the GM
// base and source one, source two, and the destination supply zero.
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
