// PTO-INSTRUCTION: {"assembly":["srl SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[429],"catalog_records":[{"asm":"srl SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00005005","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"srl_32_5cfca42c59f3","length_bits":32,"mnemonic":"SRL","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"SRL performs a logical right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["srl SrcL, SrcR, ->{t, u, Rd}"],"defaults":["SrcL, SrcR, and RegDst are required fields; no field can be omitted.","The low six bits of the snapshotted SrcR select the shift amount 0 through 63; every higher SrcR bit is ignored for the amount."],"encoding_class":"standalone-encoded","examples":["srl a0, a1, ->a2","srl t#1, u#1, ->u","srl zero, zero, ->zero"],"exceptions":["SRL raises no arithmetic exception; shifted-out bits are discarded.","An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads zero and therefore selects shift amount zero."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.","All SrcR values are legal; only its low six bits contribute to the shift amount."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 value source"},{"field":"SrcR","role":"Reg5 shift-count source"}],"ordering":["Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.","Publish the result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Compute the logical right shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.","Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.","No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SRL","mnemonic":"SRL","summary":"SRL performs a logical right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SRL-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0026.
// SRL MUST snapshot its scalar sources, apply its mnemonic-owned
// width, immediate, modifier, and wrapping rule, then publish through the
// assigned destination or commit effect in alias-safe order.
// NDF-END: PTO-SRL-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SRL()
    => ScalarOperation
begin
    return ScalarOperation_SRL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SRL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SRL(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SRL(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRL(right);
    let shifted = LSR(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SRL()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
