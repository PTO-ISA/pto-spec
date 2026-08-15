// PTO-INSTRUCTION: {"assembly":["andiw SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[9],"catalog_records":[{"asm":"andiw SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002035","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"andiw_32_9ec1f7343dbd","length_bits":32,"mnemonic":"ANDIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","semantic_summary":"ANDIW ANDs SrcL[31:0] with the low 32 bits of sign-extended simm12, sign-extends the result to XLEN, and publishes it through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["andiw SrcL, simm, ->{t, u, Rd}"],"defaults":["SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.","simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero."],"encoding_class":"standalone-encoded","examples":["andiw a0, -1, ->a0","andiw u#1, 2047, ->t","andiw zero, -2048, ->zero"],"exceptions":["ANDIW raises no arithmetic exception; word conjunction and final sign extension are defined for every source and simm12 bit pattern.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result and does not modify any GPR or queue.","SrcL":"Encoded zero reads the architectural zero GPR.","simm12":"Encoded zero supplies numeric zero."},"legality":["All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.","All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.","Every signed 12-bit immediate from -2048 through 2047 is legal. Only the low 32 bits of SrcL and the sign-extended immediate participate."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 scalar destination or discard selector"},{"field":"SrcL","role":"Reg5 scalar source; only bits 31:0 participate"},{"field":"simm12","role":"signed 12-bit immediate"}],"ordering":["Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.","Successful execution publishes the sign-extended word result and then advances TPC by four bytes."],"standalone_opcode":true,"state_effects":["Sign-extend simm12, AND its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.","Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.","No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-ANDIW","mnemonic":"ANDIW","summary":"ANDIW performs word conjunction with a signed 12-bit immediate and sign-extends the result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ANDIW()
    => ScalarOperation
begin
    return ScalarOperation_ANDIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ANDIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ANDIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDIW()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
