// PTO-INSTRUCTION: {"assembly":["slli SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[430],"catalog_records":[{"asm":"slli SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfc00707f","match":"0x00007015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"slli_32_b43ca2454e3a","length_bits":32,"mnemonic":"SLLI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"SLLI logically shifts the snapshotted XLEN source left by the encoded six-bit amount and publishes the XLEN result through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["slli SrcL, shamt, ->{t, u, Rd}"],"defaults":["SrcL, shamt, and RegDst are required fields; no field can be omitted.","shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift."],"encoding_class":"standalone-encoded","examples":["slli a0, 1, ->a0","slli t#1, 63, ->u","slli zero, 0, ->zero"],"exceptions":["SLLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the right.","Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","shamt":"Encoded zero performs no shift."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.","Every 6-bit shift amount from 0 through 63 is legal."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 source"},{"field":"shamt","role":"six-bit shift amount"}],"ordering":["Snapshot SrcL before the destination effect so aliases read the pre-instruction value.","Publish the result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Compute the XLEN logical left shift LSL(SrcL, shamt); discard bits shifted beyond bit PTO_XLEN-1 and insert zero bits at the right.","Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.","No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SLLI","mnemonic":"SLLI","summary":"SLLI performs an XLEN logical left shift by a six-bit immediate.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SLLI()
    => ScalarOperation
begin
    return ScalarOperation_SLLI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SLLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SLLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SLLI()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
