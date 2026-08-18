// PTO-INSTRUCTION: {"assembly":["c.sub srcL, srcR, ->t"],"block":[],"catalog_indices":[45],"catalog_records":[{"asm":"c.sub srcL, srcR, ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0018","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_sub_16_ff0056ac7053","length_bits":16,"mnemonic":"C.SUB","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"C.SUB snapshots two complete Reg5 sources, subtracts SrcR from SrcL modulo 2^XLEN, and pushes the result to T.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.sub srcL, srcR, ->t"],"defaults":["SrcL and SrcR are required encoded fields; neither source can be omitted.","The destination is not encoded: every successful form pushes exactly one result to T."],"encoding_class":"standalone-encoded","examples":["c.sub t#1, u#1, ->t"],"exceptions":["Ordered subtraction is a total fixed-width operation and raises no arithmetic exception.","An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR."},"legality":["Each source code 0..23 selects an absolute GPR, 24..27 selects T#1..T#4, and 28..31 selects U#1..U#4 without consumption.","Duplicate, absolute-relative, and relative-relative source pairs are legal. Every encoded source value is assigned."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left Reg5 source"},{"field":"SrcR","role":"right Reg5 source"}],"ordering":["Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.","Push the result as the newest T entry, then advance TPC by two bytes."],"standalone_opcode":true,"state_effects":["Compute SrcL minus SrcR modulo 2^PTO_XLEN; underflow wraps.","Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.","No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SUB","mnemonic":"C.SUB","summary":"C.SUB snapshots two complete Reg5 sources, subtracts SrcR from SrcL modulo 2^XLEN, and pushes the result to T.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SUB() => ScalarOperation
begin
    return ScalarOperation_C_SUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SUB(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SUB,
        left,
        right);
end;
// DOC-END: operation
