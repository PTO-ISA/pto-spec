// PTO-INSTRUCTION: {"assembly":["B.ASSEMBLE INIT, LAST, RegSrc, uimm11, WriterSizeCode"],"block":[],"catalog_indices":[75],"catalog_records":[{"asm":"B.ASSEMBLE INIT, LAST, RegSrc, uimm11, WriterSizeCode","constraints":[{"field":"INIT","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"WriterSizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001053","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"INIT","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"uimm11","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":11}],"signedness":"unsigned","width":11},{"name":"RegSrc","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"LAST","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"WriterSizeCode","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"b_assemble_32_122000000002","length_bits":32,"mnemonic":"B.ASSEMBLE","semantic_family":"CMD","semantic_group":"Bundle Range Modifier","semantic_handler":"ApplyBundleAssemble","semantic_summary":"Decodes one writer-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group."],"canonical_assembly":["B.ASSEMBLE INIT, LAST, RegSrc, uimm11, WriterSizeCode"],"defaults":["uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR. INIT=0 encodes MIDDLE/LAST; INIT=1 encodes INIT/INIT_LAST."],"encoding_class":"standalone-encoded","examples":["B.IOT T0, mask=1111, ->T1<1>; B.ASSEMBLE 1, 1, a0, 0, 10"],"exceptions":["Reserved funct3/opcode and RegSrc24..31 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance; raw WriterSizeCode 13..15 is reserved and raises Fault_IllegalInstruction.","Participating INIT, MIDDLE, and LAST writers require a legal nonzero WriterSizeCode; raw reserved codes raise Fault_IllegalInstruction.","Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl."],"field_contracts":{},"field_zero_meanings":{"INIT":"Zero selects MIDDLE/LAST rather than INIT/INIT_LAST.","LAST":"One closes the modifier sequence at the semantic assembler.","uimm11":"Zero is a real zero displacement.","RegSrc":"Zero names the architectural zero GPR.","WriterSizeCode":"Zero is reserved for discarded groups; participating writers require a nonzero extent."},"legality":["RegSrc accepts only absolute GPR selectors 0..23.","WriterSizeCode raw values 0..12 are decoded; raw values 13..15 are reserved and raise Fault_IllegalInstruction; INIT/size combinations select INIT, MIDDLE, LAST, or INIT_LAST and contradictory combinations are BundleControl.","Local WriterSizeCode values 1..10 and Shared WriterSizeCode values 1..12 are accepted in every phase; Local continuation identity is carried by the final source-form binder slot, while Shared continuation reuses the final B.IOS SizeCode=0 destination and selects the exact OPEN Sx generation.","The modifier is legal only in the contiguous immediately preceding binder group and follows source roles."],"memory_effects":["none"],"operands":[{"field":"INIT","role":"selects INIT versus MIDDLE/LAST form"},{"field":"LAST","role":"marks the final assembler carrier"},{"field":"RegSrc","role":"absolute GPR selector"},{"field":"uimm11","role":"unsigned XLEN addend"},{"field":"WriterSizeCode","role":"current writer extent code"}],"ordering":["Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality."],"state_effects":["Store raw INIT/LAST/RegSrc/uimm11/WriterSizeCode and the derived XLEN offset in the destination carrier of the open binder group.","PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects."],"standalone_opcode":true},"depends_on":["PTO-BLOCK-B-IOT","PTO-BLOCK-B-IOS","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"],"id":"PTO-BLOCK-B-ASSEMBLE","mnemonic":"B.ASSEMBLE","summary":"Decodes one writer-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-ASSEMBLE-RANGE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.ASSEMBLE MUST decode the exact 0x53 form, preserve raw controls and the
// XLEN-wrapped GPR-plus-uimm11 offset, and apply only to its preceding
// contiguous B.IOT/B.IOS group. WriterSizeCode is the current nonzero writer
// extent in INIT, MIDDLE, and LAST; parent capacity comes from the allocating
// binder SizeCode on INIT, the selected Local ParentRef on Local continuation,
// or the exact OPEN Shared generation selected by a reused Shared destination.
// INIT allocates a parent using the preceding destination-form binder's
// SizeCode as ParentCapacity. A Local continuation uses the final source-form
// binder as exactly one AssembleParentRef; a Shared continuation instead
// contextually reclassifies the final B.IOS SharedTileID with SizeCode=0 as
// one reused destination, with no allocation and no ParentRef state.
// WriterSizeCode is nonzero in every participating phase and its range must
// fit the selected parent's capacity. INIT/LAST combinations select INIT,
// MIDDLE, LAST, or INIT_LAST; they do not alter the WriterSizeCode meaning.
// NDF-END: PTO-B-ASSEMBLE-RANGE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_ASSEMBLE(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_assemble_32_122000000002;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractWriterSizeCodeIsRawLegal_B_ASSEMBLE(code: integer {0..15}) => boolean
begin
    return code <= 12;
end;

readonly func InstructionContractHandler_B_ASSEMBLE() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleAssemble;
end;
// DOC-END: operation
