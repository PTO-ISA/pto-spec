// PTO-INSTRUCTION: {"assembly":["c.srli t#1, uimm, ->t"],"block":[],"catalog_indices":[51],"catalog_records":[{"asm":"c.srli t#1, uimm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x182c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"uimm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"c_srli_16_b411862f7820","length_bits":16,"mnemonic":"C.SRLI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"C.SRLI snapshots the pre-instruction T#1 value, logically shifts it right by uimm5, and pushes the XLEN result to T.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.srli t#1, uimm, ->t"],"defaults":["T#1 is the fixed source and T is the fixed destination; neither is encoded or omittable in canonical assembly.","uimm5 is required and directly encodes a shift amount from 0 through 31."],"encoding_class":"standalone-encoded","examples":["c.srli t#1, 31, ->t"],"exceptions":["The logical shift is total and raises no arithmetic exception.","If T#1 is unavailable, Fault_IllegalInstruction is raised before the T push, before TPC advances, and before any other effect."],"field_contracts":{},"field_zero_meanings":{"uimm5":"Encoded zero republishes the unchanged pre-instruction T#1 value."},"legality":["Every uimm5 value 0..31 is assigned. Fixed encoding bits must match the canonical form.","The fixed T#1 source must be initialized before execution."],"memory_effects":["none"],"operands":[{"field":"uimm5","role":"unsigned five-bit logical right-shift amount"}],"ordering":["Snapshot old T#1 before the destination push, so the instruction cannot read its own result.","Push the shifted result as the newest T entry, then advance TPC by two bytes."],"standalone_opcode":true,"state_effects":["Logically shift the complete XLEN old T#1 value right by UInt(uimm5); shifted-out bits are discarded and vacated bits are zero-filled.","Push exactly one XLEN result to T. Existing T entries shift toward older indices and the former T#4 is discarded.","No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SRLI","mnemonic":"C.SRLI","summary":"C.SRLI snapshots the pre-instruction T#1 value, logically shifts it right by uimm5, and pushes the XLEN result to T.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SRLI() => ScalarOperation
begin
    return ScalarOperation_C_SRLI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SRLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SRLI(
    old_t1: Word,
    encoded_amount: bits(5))
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SRL,
        old_t1,
        ZeroExtend{PTO_XLEN}(encoded_amount));
end;
// DOC-END: operation
