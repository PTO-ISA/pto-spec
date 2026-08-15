// PTO-INSTRUCTION: {"assembly":["min SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[368],"catalog_records":[{"asm":"min SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x0000505b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"min_32_25692b799267","length_bits":32,"mnemonic":"MIN","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"MIN performs a signed full-XLEN comparison and publishes the complete bit pattern of the minimum operand.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["min SrcL, SrcR, ->{t, u, Rd}"],"defaults":["SrcL, SrcR, and RegDst are required fields; no field can be omitted.","Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result."],"encoding_class":"standalone-encoded","examples":["min a0, a1, ->a2","min t#1, u#1, ->u","min zero, zero, ->zero"],"exceptions":["MIN raises no arithmetic exception; comparison selects one unchanged operand bit pattern.","Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.","The operands use a signed full-XLEN comparison; every XLEN bit pattern is legal."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left Reg5 source"},{"field":"SrcR","role":"right Reg5 source"}],"ordering":["Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.","Publish the selected operand, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Perform a signed full-XLEN comparison and return the complete bit pattern of the minimum operand; equal operands are observationally identical.","Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.","No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-MIN","mnemonic":"MIN","summary":"MIN performs a signed full-XLEN comparison and publishes the complete bit pattern of the minimum operand.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MIN()
    => ScalarOperation
begin
    return ScalarOperation_MIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MIN(left: Word, right: Word)
    => Word
begin
    if SInt(left) < SInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MIN()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
