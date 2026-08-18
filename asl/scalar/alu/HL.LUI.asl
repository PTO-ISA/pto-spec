// PTO-INSTRUCTION: {"assembly":["hl.lui imm, ->{t, u, Rd}"],"block":[],"catalog_indices":[195],"catalog_records":[{"asm":"hl.lui imm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x00000017000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"encoding-defined","width":32}],"form_id":"hl_lui_48_255991889818","length_bits":48,"mnemonic":"HL.LUI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLongUpper","semantic_summary":"HL.LUI places its split 32-bit immediate in result bits 63:32 and clears result bits 31:0.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.lui imm, ->{t, u, Rd}"],"defaults":["Every encoded source, immediate, and explicit destination field is required; no field can be omitted.","The mnemonic fixes unsigned immediate placement in result bits 63:32 and the common explicit destination behavior."],"encoding_class":"standalone-encoded","examples":["hl.lui imm, ->{t, u, rd}"],"exceptions":["Materialization is a total fixed-width operation and raises no arithmetic exception.","A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","imm":"Encoded zero materializes numeric zero."},"legality":["RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every encoded operand value is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"imm","role":"split 32-bit immediate placed in result bits 63:32"}],"ordering":["Reassemble the complete encoded immediate before the destination effect.","Publish the upper-half result, then advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Reassemble imm from its two encoded pieces, zero-extend it to XLEN, shift it left by 32, and clear result bits 31:0.","Publish the complete XLEN result through the common Reg5 destination map. Only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-LUI","mnemonic":"HL.LUI","summary":"HL.LUI places its split 32-bit immediate in result bits 63:32 and clears result bits 31:0.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-LUI-UPPER-HALF-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.LUI MUST reconstruct its encoded 32-bit immediate, place it in result
// bits 63:32, clear result bits 31:0, and publish through RegDst.
// Encoded immediate zero MUST materialize zero.
// NDF-END: PTO-HL-LUI-UPPER-HALF-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LUI() => ScalarOperation
begin
    return ScalarOperation_HL_LUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUpper;
end;

pure func InstructionContractResult_HL_LUI(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUpper(encoded_immediate);
end;
// DOC-END: operation
