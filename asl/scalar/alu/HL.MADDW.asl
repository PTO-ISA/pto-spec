// PTO-INSTRUCTION: {"assembly":["hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1"],"block":[],"catalog_indices":[221],"catalog_records":[{"asm":"hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0600707f07ff","match":"0x00007047000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_maddw_48_6fac897f0264","length_bits":48,"mnemonic":"HL.MADDW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarMultiplyAddPair","semantic_summary":"HL.MADDW computes a signed 64-bit word multiply-add result and publishes its sign-extended low and high 32-bit halves.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1"],"defaults":["Every encoded operand and destination field is required; no field can be omitted.","The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode."],"encoding_class":"standalone-encoded","examples":["hl.maddw srcl, srcr, srcd, ->dst0, dst1"],"exceptions":["Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.","An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"SrcD":"Encoded zero reads the architectural zero GPR.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","RegDst0":"Encoded zero discards the low result.","RegDst1":"Encoded zero discards the high result."},"legality":["Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior."],"memory_effects":["none"],"operands":[{"field":"RegDst0","role":"sign-extended result[31:0] Reg5 destination"},{"field":"RegDst1","role":"sign-extended result[63:32] Reg5 destination"},{"field":"SrcD","role":"addend Reg5 source"},{"field":"SrcL","role":"left multiplicand or additive Reg5 source"},{"field":"SrcR","role":"right multiplicand Reg5 source"}],"ordering":["Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.","Publish SignExtend(result[31:0]) to RegDst0, publish SignExtend(result[63:32]) to RegDst1, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Interpret SrcD[31:0], SrcL[31:0], and SrcR[31:0] as signed two-complement values; compute signed32(SrcL) * signed32(SrcR) + signed32(SrcD) modulo 2^64.","Snapshot every source and compute the complete 64-bit result before destinations. Publish SignExtend(result[31:0]) to RegDst0, then SignExtend(result[63:32]) to RegDst1.","Duplicate destinations are legal and retain the second high-word result. No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-MADDW","mnemonic":"HL.MADDW","summary":"HL.MADDW computes a signed 64-bit word multiply-add result and publishes its sign-extended low and high 32-bit halves.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-MADDW-WORD-HALVES-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.MADDW MUST interpret the low 32 bits of all three sources as signed values
// and MUST compute their multiply-add result modulo 2^64.
// RegDst0 MUST receive SignExtend(result[31:0]) before RegDst1 receives
// SignExtend(result[63:32]). Sources MUST be snapshotted before either write.
// NDF-END: PTO-HL-MADDW-WORD-HALVES-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MADDW() => ScalarOperation
begin
    return ScalarOperation_HL_MADDW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
pure func InstructionContractResult_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    let effective_addend = SignExtend{PTO_XLEN}(addend[31:0]);
    let effective_left = SignExtend{PTO_XLEN}(left[31:0]);
    let effective_right = SignExtend{PTO_XLEN}(right[31:0]);
    let product = MultiplyWideSigned(effective_left, effective_right);
    return product[63:0] + effective_addend;
end;

pure func InstructionContractLow_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[31:0]);
end;

pure func InstructionContractHigh_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[63:32]);
end;
// DOC-END: operation
