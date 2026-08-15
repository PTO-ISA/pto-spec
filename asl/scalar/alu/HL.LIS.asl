// PTO-INSTRUCTION: {"assembly":["hl.lis simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[201],"catalog_records":[{"asm":"hl.lis simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x0000000d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"signed","width":32}],"form_id":"hl_lis_48_908853d6ef87","length_bits":48,"mnemonic":"HL.LIS","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLongSigned","semantic_summary":"HL.LIS sign-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.lis simm, ->{t, u, Rd}"],"defaults":["Every encoded source, immediate, and explicit destination field is required; no field can be omitted.","The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior."],"encoding_class":"standalone-encoded","examples":["hl.lis simm, ->{t, u, rd}"],"exceptions":["Materialization is a total fixed-width operation and raises no arithmetic exception.","A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","simm32":"Encoded zero materializes numeric zero."},"legality":["RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every encoded operand value is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"simm32","role":"signed split 32-bit immediate"}],"ordering":["Snapshot any Reg5 source before the destination effect.","Publish the result, then advance TPC by the encoded instruction length."],"standalone_opcode":true,"state_effects":["Reassemble simm32 from its two encoded pieces and sign-extend bit 31 through XLEN.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-LIS","mnemonic":"HL.LIS","summary":"HL.LIS sign-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LIS() => ScalarOperation
begin
    return ScalarOperation_HL_LIS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LIS() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;

pure func InstructionContractResult_HL_LIS(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongSigned(encoded_immediate);
end;
// DOC-END: operation
