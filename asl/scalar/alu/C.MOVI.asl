// PTO-INSTRUCTION: {"assembly":["c.movi simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[31],"catalog_records":[{"asm":"c.movi simm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x003f","match":"0x0016","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_movi_16_2c84faf1bc72","length_bits":16,"mnemonic":"C.MOVI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MoveScalarValue","semantic_summary":"C.MOVI sign-extends its encoded five-bit immediate to XLEN and publishes it through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.movi simm, ->{t, u, Rd}"],"defaults":["Every encoded source, immediate, and explicit destination field is required; no field can be omitted.","The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior."],"encoding_class":"standalone-encoded","examples":["c.movi simm, ->{t, u, rd}"],"exceptions":["Materialization is a total fixed-width operation and raises no arithmetic exception.","A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","simm5":"Encoded zero materializes numeric zero."},"legality":["RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every encoded operand value is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"simm5","role":"signed five-bit immediate"}],"ordering":["Snapshot any Reg5 source before the destination effect.","Publish the result, then advance TPC by the encoded instruction length."],"standalone_opcode":true,"state_effects":["Sign-extend simm5[4] through the complete XLEN result.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-MOVI","mnemonic":"C.MOVI","summary":"C.MOVI sign-extends its encoded five-bit immediate to XLEN and publishes it through RegDst.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_MOVI() => ScalarOperation
begin
    return ScalarOperation_C_MOVI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_MOVI() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVI(
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return MoveScalarValue(immediate);
end;
// DOC-END: operation
