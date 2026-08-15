// PTO-INSTRUCTION: {"assembly":["c.addi srcL, simm, ->t"],"block":[],"catalog_indices":[32],"catalog_records":[{"asm":"c.addi srcL, simm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x000c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_addi_16_3050744f2322","length_bits":16,"mnemonic":"C.ADDI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"C.ADDI snapshots one complete Reg5 source, sign-extends simm5, adds modulo 2^XLEN, and pushes the result to T.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.addi srcL, simm, ->t"],"defaults":["SrcL and signed simm5 are required encoded fields; neither can be omitted.","The destination is not encoded: every successful form pushes exactly one result to T."],"encoding_class":"standalone-encoded","examples":["c.addi t#1, -1, ->t"],"exceptions":["Fixed-width addition is total and raises no arithmetic exception.","An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR.","simm5":"Encoded zero supplies numeric zero."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","Every simm5 encoding is assigned and denotes a signed integer from -16 through +15."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"Reg5 addend"},{"field":"simm5","role":"signed five-bit addend"}],"ordering":["Snapshot SrcL and sign-extend simm5 before pushing the destination.","Push the result as the newest T entry, then advance TPC by two bytes."],"standalone_opcode":true,"state_effects":["Sign-extend simm5 to XLEN and add it to SrcL modulo 2^PTO_XLEN.","Push exactly one XLEN result to T without consuming the source. Existing T entries shift toward older indices.","No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-ADDI","mnemonic":"C.ADDI","summary":"C.ADDI snapshots one complete Reg5 source, sign-extends simm5, adds modulo 2^XLEN, and pushes the result to T.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_ADDI() => ScalarOperation
begin
    return ScalarOperation_C_ADDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_ADDI(
    left: Word,
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return ScalarBinary(
        ScalarBinary_ADD,
        left,
        immediate);
end;
// DOC-END: operation
