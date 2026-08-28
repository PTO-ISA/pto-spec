// PTO-INSTRUCTION: {"assembly":["B.SUBVIEW SrcSelect, RegSrc, uimm11, SubviewSizeCode"],"block":[],"catalog_indices":[74],"catalog_records":[{"asm":"B.SUBVIEW SrcSelect, RegSrc, uimm11, SubviewSizeCode","constraints":[{"field":"SrcSelect","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SubviewSizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10,11,12]}],"encoding":[{"index":0,"mask":"0x0000787f","match":"0x00000053","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcSelect","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"uimm11","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":11}],"signedness":"unsigned","width":11},{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SubviewSizeCode","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"b_subview_32_122000000001","length_bits":32,"mnemonic":"B.SUBVIEW","semantic_family":"CMD","semantic_group":"Bundle Range Modifier","semantic_handler":"ApplyBundleSubview","semantic_summary":"Decodes one source-range subview modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group."],"canonical_assembly":["B.SUBVIEW SrcSelect, RegSrc, uimm11, SubviewSizeCode"],"defaults":["uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR."],"encoding_class":"standalone-encoded","examples":["B.IOT T0, mask=1111; B.SUBVIEW 0, a0, 0, 1"],"exceptions":["Reserved funct3/bit11/opcode, RegSrc24..31, and SubviewSizeCode0/13..15 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance.","Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl before carrier updates."],"field_contracts":{},"field_zero_meanings":{"SrcSelect":"Zero selects source role zero.","uimm11":"Zero is a real zero displacement.","RegSrc":"Zero names the architectural zero GPR.","SubviewSizeCode":"Zero is reserved."},"legality":["RegSrc accepts only absolute GPR selectors 0..23.","SubviewSizeCode raw values 1..12 are decoded; Local-associated groups require 1..10 and Shared-associated groups accept 1..12.","A modifier is legal only in the contiguous immediately preceding B.IOT/B.IOS group and follows source0, source1, destination role order."],"memory_effects":["none"],"operands":[{"field":"SrcSelect","role":"selects source0 or source1 carrier"},{"field":"RegSrc","role":"absolute GPR selector"},{"field":"uimm11","role":"unsigned XLEN addend"},{"field":"SubviewSizeCode","role":"decoded source tile range size"}],"ordering":["Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality."],"state_effects":["Store raw RegSrc/uimm11/size and the derived XLEN offset in the source carrier of the open binder group.","PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects."],"standalone_opcode":true},"depends_on":["PTO-BLOCK-B-IOT","PTO-BLOCK-B-IOS","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"],"id":"PTO-BLOCK-B-SUBVIEW","mnemonic":"B.SUBVIEW","summary":"Decodes one source-range subview modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-SUBVIEW-RANGE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.SUBVIEW MUST decode the exact 0x53 form, preserve raw fields and the
// XLEN-wrapped GPR-plus-uimm11 offset, and apply only to its preceding
// contiguous B.IOT/B.IOS group.
// Raw SizeCodes 11 and 12 attached to a Local group MUST raise
// Fault_TileLegality before GPR reads or carrier updates; the same raw codes
// attached to a Shared group remain legal.
// NDF-END: PTO-B-SUBVIEW-RANGE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_SUBVIEW(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_subview_32_122000000001;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractSubviewSizeCodeIsAssigned_B_SUBVIEW(code: integer {0..15}) => boolean
begin
    return 1 <= code && code <= 12;
end;

readonly func InstructionContractHandler_B_SUBVIEW() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleSubview;
end;
// DOC-END: operation
