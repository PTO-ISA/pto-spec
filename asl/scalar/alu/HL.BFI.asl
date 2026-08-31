// PTO-INSTRUCTION: {"assembly":["hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[122],"catalog_records":[{"asm":"hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}","constraints":[{"field":"immr","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"imms","operator":"one-of","values":[0,1,2,3,4,5,6,7]}],"encoding":[{"index":0,"mask":"0xfe00707f000f","match":"0x0000204d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"immr","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":10,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"hl_bfi_48_8adfd476aacc","length_bits":48,"mnemonic":"HL.BFI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"InsertBitfield","semantic_summary":"HL.BFI copies a low source byte field into a wrapping byte interval of a snapshotted base value and publishes the XLEN result.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}"],"defaults":["SrcL, SrcR, immr, imms, and RegDst are required encoded fields; no field can be omitted.","immr encodes byte count N minus one in the assigned range 0 through 7. imms encodes destination byte offset M in the assigned range 0 through 7.","When M plus N exceeds eight, destination byte selection wraps through byte seven to byte zero. Source bytes are consumed in ascending order from byte zero."],"encoding_class":"standalone-encoded","examples":["hl.bfi a0, a1, 4, 4, ->a2","hl.bfi t#1, u#1, 7, 2, ->t","hl.bfi a0, zero, 0, 8, ->a0"],"exceptions":["An imms or immr encoding above 7, or an unavailable selected T/U source, raises Fault_IllegalInstruction before source reads, destination effect, or TPC advance. Both sources are preflighted even when their encoded values are equal.","HL.BFI raises no arithmetic, memory, alignment, permission, or control-flow exception."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR base.","SrcR":"Encoded zero reads the architectural zero GPR insertion source.","immr":"Encoded zero selects a one-byte field (N=1).","imms":"Encoded zero begins insertion at destination byte zero (M=0)."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","immr values 0 through 7 encode N=1 through 8 bytes and imms values 0 through 7 encode M=0 through 7; all larger six-bit values are reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 base source"},{"field":"SrcR","role":"Reg5 insertion source"},{"field":"immr","role":"inserted byte count N minus one"},{"field":"imms","role":"destination byte offset M"}],"ordering":["Snapshot both sources before any destination effect, including when RegDst aliases SrcL or SrcR.","Publish the result, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Snapshot the base and insertion sources. Copy the low N source bytes into N destination bytes beginning at byte M, wrapping modulo eight destination bytes; preserve every unselected base byte.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING","PTO-SCALAR-MODEL-ALU-BITFIELD"],"id":"PTO-SCALAR-HL-BFI","mnemonic":"HL.BFI","summary":"HL.BFI copies a low source byte field into a wrapping byte interval of a snapshotted base value and publishes the XLEN result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-BFI-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.BFI MUST interpret imms as destination byte M in 0..7 and immr as N-1
// for byte count N in 1..8. It MUST copy the low N source bytes into the N
// destination bytes beginning at M with modulo-eight destination wrapping.
// Larger imms or immr encodings MUST be rejected before architectural effects.
// NDF-END: PTO-HL-BFI-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_BFI()
    => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;

pure func InstructionContractByteCount_HL_BFI(encoded_immr: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_immr) + 1;
end;

pure func InstructionContractByteOffset_HL_BFI(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_BFI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;

pure func InstructionContractResult_HL_BFI(
    base: Word,
    source: Word,
    byte_offset: integer {0..7},
    byte_count: integer {1..8})
    => Word
begin
    return InsertByteField(
        base,
        source,
        byte_offset,
        byte_count);
end;
// DOC-END: operation
