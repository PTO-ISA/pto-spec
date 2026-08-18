// PTO-INSTRUCTION: {"assembly":["slliw SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[423],"catalog_records":[{"asm":"slliw SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00007035","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"slliw_32_c6bf463b97ae","length_bits":32,"mnemonic":"SLLIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","semantic_summary":"SLLIW logically shifts SrcL[31:0] left by the encoded five-bit amount, sign-extends the word result to XLEN, and publishes it.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["slliw SrcL, shamt, ->{t, u, Rd}"],"defaults":["SrcL, shamt, and RegDst are required fields; no field can be omitted.","shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift."],"encoding_class":"standalone-encoded","examples":["slliw a0, 1, ->a0","slliw u#1, 31, ->t","slliw zero, 0, ->zero"],"exceptions":["SLLIW raises no arithmetic exception; shifted-out word bits are discarded and the final word is sign-extended to XLEN.","Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","shamt":"Encoded zero performs no shift."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.","Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 source; low 32 bits used"},{"field":"shamt","role":"five-bit shift amount"}],"ordering":["Snapshot SrcL before the destination effect so aliases read the pre-instruction value.","Publish the sign-extended word result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Compute the 32-bit logical left shift LSL(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.","Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.","No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SLLIW","mnemonic":"SLLIW","summary":"SLLIW performs a word logical left shift and sign-extends the result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SLLIW-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0026.
// SLLIW MUST snapshot its scalar sources, apply its mnemonic-owned
// width, immediate, modifier, and wrapping rule, then publish through the
// assigned destination or commit effect in alias-safe order.
// NDF-END: PTO-SLLIW-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SLLIW()
    => ScalarOperation
begin
    return ScalarOperation_SLLIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SLLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SLLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SLLIW()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
