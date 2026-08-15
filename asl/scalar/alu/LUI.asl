// PTO-INSTRUCTION: {"assembly":["lui simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[347],"catalog_records":[{"asm":"lui simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000017","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"lui_32_982113b541d6","length_bits":32,"mnemonic":"LUI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLUI","semantic_summary":"LUI sign-extends its encoded 20-bit immediate to XLEN, shifts it left by 12 bits, and publishes the result through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["lui simm, ->{t, u, Rd}"],"defaults":["Every encoded source, immediate, and explicit destination field is required; no field can be omitted.","The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior."],"encoding_class":"standalone-encoded","examples":["lui simm, ->{t, u, rd}"],"exceptions":["Materialization is a total fixed-width operation and raises no arithmetic exception.","A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","imm20":"Encoded zero materializes numeric zero."},"legality":["RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every encoded operand value is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"imm20","role":"signed upper 20-bit immediate"}],"ordering":["Snapshot any Reg5 source before the destination effect.","Publish the result, then advance TPC by the encoded instruction length."],"standalone_opcode":true,"state_effects":["Sign-extend imm20 to XLEN, shift left by 12, and discard overflow beyond XLEN.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-LUI","mnemonic":"LUI","summary":"LUI sign-extends its encoded 20-bit immediate to XLEN, shifts it left by 12 bits, and publishes the result through RegDst.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LUI() => ScalarOperation
begin
    return ScalarOperation_LUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLUI;
end;

pure func InstructionContractResult_LUI(
    encoded_immediate: bits(20))
    => Word
begin
    return MaterializeLUI(encoded_immediate);
end;
// DOC-END: operation
