// PTO-INSTRUCTION: {"assembly":["srliw SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[431],"catalog_records":[{"asm":"srliw SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00005035","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"srliw_32_ef4aa650f46e","length_bits":32,"mnemonic":"SRLIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","semantic_summary":"SRLIW logically shifts SrcL[31:0] right by the encoded five-bit amount, sign-extends the word result to XLEN, and publishes it.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["srliw SrcL, shamt, ->{t, u, Rd}"],"defaults":["SrcL, shamt, and RegDst are required fields; no field can be omitted.","shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift."],"encoding_class":"standalone-encoded","examples":["srliw a0, 1, ->a0","srliw u#1, 31, ->t","srliw zero, 0, ->zero"],"exceptions":["SRLIW raises no arithmetic exception; zero bits enter from the left and the final word is sign-extended to XLEN.","Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","shamt":"Encoded zero performs no shift."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.","Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 source; low 32 bits used"},{"field":"shamt","role":"five-bit shift amount"}],"ordering":["Snapshot SrcL before the destination effect so aliases read the pre-instruction value.","Publish the sign-extended word result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Compute the 32-bit logical right shift LSR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.","Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.","No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SRLIW","mnemonic":"SRLIW","summary":"SRLIW performs a word logical right shift and sign-extends the result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SRLIW-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0026.
// SRLIW MUST snapshot its scalar sources, apply its mnemonic-owned
// width, immediate, modifier, and wrapping rule, then publish through the
// assigned destination or commit effect in alias-safe order.
// NDF-END: PTO-SRLIW-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SRLIW()
    => ScalarOperation
begin
    return ScalarOperation_SRLIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SRLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRLIW()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
