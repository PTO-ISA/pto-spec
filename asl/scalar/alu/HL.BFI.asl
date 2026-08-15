// PTO-INSTRUCTION: {"assembly":["hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[130],"catalog_records":[{"asm":"hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f000f","match":"0x0000204d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"immr","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":10,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"hl_bfi_48_8adfd476aacc","length_bits":48,"mnemonic":"HL.BFI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"InsertBitfield","semantic_summary":"HL.BFI inserts ascending low source bits into an inclusive wrapping destination interval of a snapshotted base value and publishes the XLEN result.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}"],"defaults":["SrcL, SrcR, immr, imms, and RegDst are required encoded fields; no field can be omitted.","immr directly encodes the first destination bit from 0 through 63. imms directly encodes the last destination bit from 0 through 63.","When imms precedes immr, the inclusive destination interval wraps through bit 63 to bit 0. Equal endpoints select one destination bit."],"encoding_class":"standalone-encoded","examples":["hl.bfi a0, a1, 8, 15, ->a2","hl.bfi t#1, u#1, 63, 0, ->t","hl.bfi a0, zero, 0, 63, ->a0"],"exceptions":["An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances. Both sources are preflighted even when their encoded values are equal.","HL.BFI raises no arithmetic, memory, alignment, permission, or control-flow exception."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR base.","SrcR":"Encoded zero reads the architectural zero GPR insertion source.","immr":"Encoded zero begins the destination interval at bit zero.","imms":"Encoded zero ends the destination interval at bit zero."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every immr and imms value is assigned. The inclusive wrapping interval has a width from 1 through 64."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 base source"},{"field":"SrcR","role":"Reg5 insertion source"},{"field":"immr","role":"first destination bit"},{"field":"imms","role":"last destination bit"}],"ordering":["Snapshot both sources before any destination effect, including when RegDst aliases SrcL or SrcR.","Publish the result, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Snapshot the base and insertion sources. Starting with source bit zero, replace ascending bits of the inclusive destination interval from immr through imms, wrapping through bit 63 when required; preserve every base bit outside that interval.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-BFI","mnemonic":"HL.BFI","summary":"HL.BFI inserts ascending low source bits into an inclusive wrapping destination interval of a snapshotted base value and publishes the XLEN result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_BFI()
    => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;

pure func InstructionContractFirstBit_HL_BFI(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;

pure func InstructionContractLastBit_HL_BFI(encoded_imms: bits(6))
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
    first: integer {0..63},
    last: integer {0..63})
    => Word
begin
    return InsertBitfield(
        base,
        source,
        first,
        last);
end;
// DOC-END: operation
