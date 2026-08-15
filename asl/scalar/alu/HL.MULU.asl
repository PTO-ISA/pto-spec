// PTO-INSTRUCTION: {"assembly":["hl.mulu SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[233],"catalog_records":[{"asm":"hl.mulu SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00001047000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_mulu_48_85efdc81e8fc","length_bits":48,"mnemonic":"HL.MULU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarMultiplyPair","semantic_summary":"HL.MULU computes an unsigned 128-bit scalar product and publishes its low half followed by its high half.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.mulu SrcL, SrcR, ->Dst0, Dst1"],"defaults":["Every encoded operand and destination field is required; no field can be omitted.","The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode."],"encoding_class":"standalone-encoded","examples":["hl.mulu srcl, srcr, ->dst0, dst1"],"exceptions":["Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.","An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","RegDst0":"Encoded zero discards the low result.","RegDst1":"Encoded zero discards the high result."},"legality":["Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior."],"memory_effects":["none"],"operands":[{"field":"RegDst0","role":"low product or accumulator Reg5 destination"},{"field":"RegDst1","role":"high product or accumulator Reg5 destination"},{"field":"SrcL","role":"left multiplicand or additive Reg5 source"},{"field":"SrcR","role":"right multiplicand Reg5 source"}],"ordering":["Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.","Publish the low result to RegDst0, publish the high result to RegDst1, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Zero-extend both XLEN sources into an unsigned 128-bit product.","Snapshot every source and compute the complete 128-bit result before destinations. Publish bits 63:0 to RegDst0, then bits 127:64 to RegDst1. Duplicate destinations are legal; the second high result is final/newest.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-MULU","mnemonic":"HL.MULU","summary":"HL.MULU computes an unsigned 128-bit scalar product and publishes its low half followed by its high half.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MULU() => ScalarOperation
begin
    return ScalarOperation_HL_MULU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
pure func InstructionContractProduct_HL_MULU(left: Word, right: Word) => DoubleWord
begin
    return MultiplyWideUnsigned(left, right);
end;

pure func InstructionContractLow_HL_MULU(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MULU(left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MULU(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MULU(left, right)[127:64];
end;
// DOC-END: operation
