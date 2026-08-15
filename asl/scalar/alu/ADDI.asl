// PTO-INSTRUCTION: {"assembly":["addi SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[3],"catalog_records":[{"asm":"addi SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"unsigned","width":12}],"form_id":"addi_32_2decd0a93a0a","length_bits":32,"mnemonic":"ADDI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"ADDI adds the zero-extended unsigned 12-bit immediate to the snapshotted XLEN source modulo 2^PTO_XLEN and publishes the result through the selected Reg5 destination.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["addi SrcL, uimm, ->{t, u, Rd}"],"defaults":["SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.","uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero."],"encoding_class":"standalone-encoded","examples":["addi a0, 1, ->a0","addi t#1, 4095, ->u","addi zero, 0, ->zero"],"exceptions":["ADDI raises no arithmetic exception: addition wraps modulo 2^PTO_XLEN.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result and does not modify any GPR or queue.","SrcL":"Encoded zero reads the architectural zero GPR.","uimm12":"Encoded zero supplies numeric zero."},"legality":["All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.","Every unsigned 12-bit immediate from 0 through 4095 is legal."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 scalar destination or discard selector"},{"field":"SrcL","role":"Reg5 scalar source"},{"field":"uimm12","role":"unsigned 12-bit immediate"}],"ordering":["Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.","Successful execution publishes the result and then advances TPC by four bytes."],"standalone_opcode":true,"state_effects":["Zero-extend uimm12, add it to the snapshotted SrcL value modulo 2^PTO_XLEN, and publish the XLEN result through RegDst.","Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.","No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-ADDI","mnemonic":"ADDI","summary":"ADDI performs unsigned-immediate XLEN addition with Reg5 source and destination selection.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ADDI()
    => ScalarOperation
begin
    return ScalarOperation_ADDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ADDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ADDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_ADDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ADDI()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
