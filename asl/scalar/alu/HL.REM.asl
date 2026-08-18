// PTO-INSTRUCTION: {"assembly":["hl.rem SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[240],"catalog_records":[{"asm":"hl.rem SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00004057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_rem_48_3c13e08615aa","length_bits":48,"mnemonic":"HL.REM","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarRemainderPair","semantic_summary":"HL.REM computes a signed XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.rem SrcL, SrcR, ->Dst0, Dst1"],"defaults":["SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.","There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder."],"encoding_class":"standalone-encoded","examples":["hl.rem a0, a1, ->a2, a3","hl.rem t#1, zero, ->u, u"],"exceptions":["Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.","An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst0":"Encoded zero discards the remainder.","RegDst1":"Encoded zero discards the quotient.","SrcL":"Encoded zero reads the architectural zero GPR dividend.","SrcR":"Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.","Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form."],"memory_effects":["none"],"operands":[{"field":"RegDst0","role":"remainder Reg5 destination or discard"},{"field":"RegDst1","role":"quotient Reg5 destination or discard"},{"field":"SrcL","role":"dividend Reg5 source"},{"field":"SrcR","role":"divisor Reg5 source"}],"ordering":["Snapshot both sources and compute both results before either destination effect.","Publish remainder to RegDst0, publish quotient to RegDst1, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Interpret the selected operands as signed values, compute both quotient and remainder using the fixed total division rules.","A zero divisor returns quotient zero and the effective dividend as remainder. Signed minimum divided by negative one returns signed minimum quotient and zero remainder.","Publish RegDst0 remainder first, then RegDst1 quotient. If both destinations name one GPR, quotient is final; if both push one queue, quotient is newest and remainder is next-newest.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-REM","mnemonic":"HL.REM","summary":"HL.REM computes a signed XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-REM-RESULT-ORDER-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.REM MUST snapshot both sources before destination effects.
// RegDst0 MUST receive the remainder before RegDst1 receives the quotient.
// Duplicate destinations and queue pushes MUST preserve that write order.
// Zero-divisor, signed-overflow, selector, and retirement behavior MUST remain
// identical to the corresponding quotient/remainder arithmetic contract.
// NDF-END: PTO-HL-REM-RESULT-ORDER-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_REM() => ScalarOperation
begin
    return ScalarOperation_HL_REM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPair;
end;
pure func InstructionContractQuotient_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSigned(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REM(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REM(
        dividend,
        divisor);
end;
// DOC-END: operation
