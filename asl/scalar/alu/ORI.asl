// PTO-INSTRUCTION: {"assembly":["ori SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[375],"catalog_records":[{"asm":"ori SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"ori_32_413a6cc76e9a","length_bits":32,"mnemonic":"ORI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"ORI sign-extends simm12 to PTO_XLEN, ORs it with the snapshotted XLEN source, and publishes the complete result through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["ori SrcL, simm, ->{t, u, Rd}"],"defaults":["SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.","simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero."],"encoding_class":"standalone-encoded","examples":["ori a0, -1, ->a0","ori t#1, 2047, ->u","ori zero, -2048, ->zero"],"exceptions":["ORI raises no arithmetic exception; bitwise disjunction is defined for every source and simm12 bit pattern.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result and does not modify any GPR or queue.","SrcL":"Encoded zero reads the architectural zero GPR.","simm12":"Encoded zero supplies numeric zero."},"legality":["All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.","All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.","Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the disjunction."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 scalar destination or discard selector"},{"field":"SrcL","role":"Reg5 scalar source"},{"field":"simm12","role":"signed 12-bit immediate"}],"ordering":["Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.","Successful execution publishes the result and then advances TPC by four bytes."],"standalone_opcode":true,"state_effects":["Sign-extend simm12 to PTO_XLEN, compute the bitwise disjunction with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.","Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.","No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-ORI","mnemonic":"ORI","summary":"ORI performs XLEN disjunction with a sign-extended signed 12-bit immediate.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ORI()
    => ScalarOperation
begin
    return ScalarOperation_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ORI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ORI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORI()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
