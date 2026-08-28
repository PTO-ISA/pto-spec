// PTO-INSTRUCTION: {"assembly":["B.ASSEMBLE INIT, LAST, RegSrc, uimm11, ParentSizeCode"],"block":[],"catalog_indices":[75],"catalog_records":[{"asm":"B.ASSEMBLE INIT, LAST, RegSrc, uimm11, ParentSizeCode","constraints":[{"field":"INIT","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"ParentSizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001053","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"INIT","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"uimm11","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":11}],"signedness":"unsigned","width":11},{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"LAST","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"ParentSizeCode","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"b_assemble_32_122000000002","length_bits":32,"mnemonic":"B.ASSEMBLE","semantic_family":"CMD","semantic_group":"Bundle Range Modifier","semantic_handler":"ApplyBundleAssemble","semantic_summary":"Decodes one destination-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group."],"canonical_assembly":["B.ASSEMBLE INIT, LAST, RegSrc, uimm11, ParentSizeCode"],"defaults":["uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR. INIT=0 encodes MIDDLE/LAST; INIT=1 encodes INIT/INIT_LAST."],"encoding_class":"standalone-encoded","examples":["B.IOT T0, mask=1111, ->T1<1>; B.ASSEMBLE 1, 1, a0, 0, 10"],"exceptions":["Reserved funct3/opcode, RegSrc24..31, and ParentSizeCode13..15 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance.","INIT=1 with ParentSizeCode=0 or INIT=0 with a nonzero ParentSizeCode raises Fault_BundleControl.","Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl."],"field_contracts":{},"field_zero_meanings":{"INIT":"Zero selects MIDDLE/LAST rather than INIT/INIT_LAST.","LAST":"One closes the modifier sequence at the semantic assembler.","uimm11":"Zero is a real zero displacement.","RegSrc":"Zero names the architectural zero GPR.","ParentSizeCode":"Zero is the MIDDLE/LAST-only no-parent-size encoding."},"legality":["RegSrc accepts only absolute GPR selectors 0..23.","ParentSizeCode raw values 0..12 are decoded; INIT/size combinations select INIT, MIDDLE, LAST, or INIT_LAST and contradictory combinations are BundleControl.","Local parent sizes 1..10 are accepted; Shared parent sizes 1..12 are accepted.","The modifier is legal only in the contiguous immediately preceding binder group and follows source roles."],"memory_effects":["none"],"operands":[{"field":"INIT","role":"selects INIT versus MIDDLE/LAST form"},{"field":"LAST","role":"marks the final assembler carrier"},{"field":"RegSrc","role":"absolute GPR selector"},{"field":"uimm11","role":"unsigned XLEN addend"},{"field":"ParentSizeCode","role":"raw parent size code"}],"ordering":["Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality."],"state_effects":["Store raw INIT/LAST/RegSrc/uimm11/ParentSizeCode and the derived XLEN offset in the destination carrier of the open binder group.","PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects."],"standalone_opcode":true},"depends_on":["PTO-BLOCK-B-IOT","PTO-BLOCK-B-IOS","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"],"id":"PTO-BLOCK-B-ASSEMBLE","mnemonic":"B.ASSEMBLE","summary":"Decodes one destination-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-ASSEMBLE-RANGE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.ASSEMBLE MUST decode the exact 0x53 form, preserve raw controls and the
// XLEN-wrapped GPR-plus-uimm11 offset, and apply only to its preceding
// contiguous B.IOT/B.IOS group.
// Raw parent SizeCodes 11 and 12 attached to a Local group MUST raise
// Fault_TileLegality before GPR reads or carrier updates; the same raw codes
// attached to a Shared group remain legal.
// NDF-END: PTO-B-ASSEMBLE-RANGE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_ASSEMBLE(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_assemble_32_122000000002;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractParentSizeCodeIsRawLegal_B_ASSEMBLE(code: integer {0..15}) => boolean
begin
    return code <= 12;
end;

readonly func InstructionContractHandler_B_ASSEMBLE() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleAssemble;
end;
// DOC-END: operation
