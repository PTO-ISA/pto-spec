// PTO-INSTRUCTION: {"assembly":["hl.subi SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[293],"catalog_records":[{"asm":"hl.subi SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00001015000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"unsigned","width":24}],"form_id":"hl_subi_48_e1f491a8aead","length_bits":48,"mnemonic":"HL.SUBI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"HL.SUBI applies XLEN subtraction to SrcL and a zero-extended 24-bit immediate.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.subi SrcL, uimm, ->{t, u, Rd}"],"defaults":["SrcL, uimm24, and RegDst are required encoded fields; no field can be omitted.","uimm24 has the complete unsigned 24-bit range 0 through 16777215; encoded zero is numeric zero."],"encoding_class":"standalone-encoded","examples":["hl.subi a0, 1, ->a0","hl.subi t#1, 16777215, ->u","hl.subi zero, 0, ->zero"],"exceptions":["HL.SUBI raises no arithmetic exception; fixed-width overflow or underflow is discarded.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result and does not modify any GPR or queue.","SrcL":"Encoded zero reads architectural GPR zero.","uimm24":"Encoded zero supplies numeric zero."},"legality":["All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.","All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.","Every unsigned 24-bit value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 scalar destination or discard selector"},{"field":"SrcL","role":"Reg5 scalar source"},{"field":"uimm24","role":"unsigned split 24-bit immediate"}],"ordering":["Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.","Publish the result through RegDst, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Zero-extend uimm24 to PTO_XLEN, compute subtraction with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.","Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.","No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SUBI","mnemonic":"HL.SUBI","summary":"HL.SUBI applies XLEN subtraction to SrcL and a zero-extended 24-bit immediate.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-SUBI-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.SUBI MUST reconstruct its split uimm24 field exactly and apply
// subtraction with a zero-extended unsigned 24-bit immediate.
// The result MUST wrap modulo 2^PTO_XLEN.
// SrcL MUST use the complete non-consuming Reg5 source map. RegDst MUST
// use the common GPR, discard, U-push, and T-push destination map.
// The source MUST be snapshotted before destination publication.
// Successful execution MUST advance TPC by six bytes and MUST NOT change
// memory, Tile, block, reservation, privilege, numeric-status, or fault state.
// NDF-END: PTO-HL-SUBI-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SUBI() => ScalarOperation
begin
    return ScalarOperation_HL_SUBI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SUBI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_SUBI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_SUBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_SUBI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_SUBI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_SUB,
        left,
        right);
end;
// DOC-END: operation
