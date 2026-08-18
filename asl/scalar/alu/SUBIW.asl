// PTO-INSTRUCTION: {"assembly":["subiw SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[438],"catalog_records":[{"asm":"subiw SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001035","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"unsigned","width":12}],"form_id":"subiw_32_51019ff77d0a","length_bits":32,"mnemonic":"SUBIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","semantic_summary":"SUBIW subtracts the zero-extended unsigned 12-bit immediate from SrcL[31:0] modulo 2^32, sign-extends the word result to XLEN, and publishes it through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["subiw SrcL, uimm, ->{t, u, Rd}"],"defaults":["SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.","uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero."],"encoding_class":"standalone-encoded","examples":["subiw a0, 1, ->a0","subiw u#1, 4095, ->t","subiw zero, 0, ->zero"],"exceptions":["SUBIW raises no arithmetic exception: word subtraction wraps modulo 2^32 and is sign-extended to XLEN.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result and does not modify any GPR or queue.","SrcL":"Encoded zero reads the architectural zero GPR.","uimm12":"Encoded zero supplies numeric zero."},"legality":["All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.","Every unsigned 12-bit immediate from 0 through 4095 is legal; source bits above bit 31 do not affect the result."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 scalar destination or discard selector"},{"field":"SrcL","role":"Reg5 scalar source; only bits 31:0 participate"},{"field":"uimm12","role":"unsigned 12-bit immediate"}],"ordering":["Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.","Successful execution publishes the sign-extended word result and then advances TPC by four bytes."],"standalone_opcode":true,"state_effects":["Subtract zero-extended uimm12 from SrcL[31:0] modulo 2^32, then sign-extend the 32-bit result to XLEN and publish it through RegDst.","Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.","No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SUBIW","mnemonic":"SUBIW","summary":"SUBIW performs unsigned-immediate word subtraction and sign-extends the result to XLEN.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SUBIW-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0026.
// SUBIW MUST snapshot its scalar sources, apply its mnemonic-owned
// width, immediate, modifier, and wrapping rule, then publish through the
// assigned destination or commit effect in alias-safe order.
// NDF-END: PTO-SUBIW-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SUBIW()
    => ScalarOperation
begin
    return ScalarOperation_SUBIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SUBIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_SUBIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_SUBIW()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
