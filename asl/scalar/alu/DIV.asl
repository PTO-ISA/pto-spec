// PTO-INSTRUCTION: {"assembly":["div SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[90],"catalog_records":[{"asm":"div SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00000057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"div_32_a6efe85f8662","length_bits":32,"mnemonic":"DIV","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarDivideSigned","semantic_summary":"DIV computes the signed XLEN quotient using total fixed-width semantics and publishes the XLEN result.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["div SrcL, SrcR, ->{t, u, Rd}"],"defaults":["SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.","There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection."],"encoding_class":"standalone-encoded","examples":["div a0, a1, ->a2","div t#1, zero, ->u"],"exceptions":["Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.","An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR dividend.","SrcR":"Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"dividend Reg5 source"},{"field":"SrcR","role":"divisor Reg5 source"}],"ordering":["Snapshot both sources before the destination effect so duplicate selectors and destination aliases observe pre-instruction values.","Publish the result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Interpret both complete XLEN sources as signed two-complement integers and return the quotient truncated toward zero.","A zero divisor returns zero. Signed minimum divided by negative one returns signed minimum.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-DIV","mnemonic":"DIV","summary":"DIV computes the signed XLEN quotient using total fixed-width semantics and publishes the XLEN result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DIV() => ScalarOperation
begin
    return ScalarOperation_DIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSigned;
end;
pure func InstructionContractResult_DIV(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;
// DOC-END: operation
