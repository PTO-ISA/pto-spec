// PTO-INSTRUCTION: {"assembly":["c.sext.b srcL, ->t"],"block":[],"catalog_indices":[39],"catalog_records":[{"asm":"c.sext.b srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x401c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_sext_b_16_8ffd07d15409","length_bits":16,"mnemonic":"C.SEXT.B","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","semantic_summary":"C.SEXT.B sign-extends SrcL[7:0] to XLEN and pushes the result to T.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.sext.b srcL, ->t"],"defaults":["Every encoded source, immediate, and explicit destination field is required; no field can be omitted.","The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior."],"encoding_class":"standalone-encoded","examples":["c.sext.b srcl, ->t"],"exceptions":["Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.","An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","The compressed form has no destination field and always pushes exactly one result to T.","Every encoded operand value is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"Reg5 source"}],"ordering":["Snapshot any Reg5 source before the destination effect.","Publish the result, then advance TPC by the encoded instruction length."],"standalone_opcode":true,"state_effects":["Sign-extend source bit 7 through the XLEN result.","Push the complete XLEN result to T. The source queue is non-consuming, and no explicit destination encoding exists.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SEXT-B","mnemonic":"C.SEXT.B","summary":"C.SEXT.B sign-extends SrcL[7:0] to XLEN and pushes the result to T.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_B;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_SEXT_B(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        8,
        TRUE);
end;
// DOC-END: operation
