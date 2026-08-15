// PTO-INSTRUCTION: {"assembly":["bis SrcL, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[24],"catalog_records":[{"asm":"bis SrcL, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"bis_32_bca5d1a80f32","length_bits":32,"mnemonic":"BIS","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ModifyBitfield","semantic_summary":"BIS sets every bit in an independently selected wrapping scalar field and publishes the modified XLEN value.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["bis SrcL, M, N, ->{t, u, Rd}"],"defaults":["SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.","imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.","imms directly encodes M from 0 through 63; encoded zero selects source bit zero."],"encoding_class":"standalone-encoded","examples":["bis a0, 60, 8, ->a1","bis t#1, 0, 64, ->u"],"exceptions":["An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.","BIS raises no arithmetic, memory, alignment, permission, or control-flow exception."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","imml":"Encoded zero selects a one-bit field.","imms":"Encoded zero starts the selected field at source bit zero."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 source"},{"field":"imml","role":"selected field width N minus one"},{"field":"imms","role":"selected field starting bit M"}],"ordering":["Snapshot SrcL before any destination effect so a GPR alias or T/U destination push observes the pre-instruction value.","Publish the result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Set the N selected source bits and preserve every unselected source bit.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-BIS","mnemonic":"BIS","summary":"BIS sets every bit in an independently selected wrapping scalar field and publishes the modified XLEN value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BIS()
    => ScalarOperation
begin
    return ScalarOperation_BIS;
end;

pure func InstructionContractWidth_BIS(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BIS(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BIS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;

pure func InstructionContractResult_BIS(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ModifyBitfield(
        value,
        width,
        offset,
        TRUE);
end;
// DOC-END: operation
