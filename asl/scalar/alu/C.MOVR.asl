// PTO-INSTRUCTION: {"assembly":["c.movr SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[32],"catalog_records":[{"asm":"c.movr SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0006","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_movr_16_80d2b5f3580b","length_bits":16,"mnemonic":"C.MOVR","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MoveScalarValue","semantic_summary":"C.MOVR snapshots a Reg5 source and publishes the complete XLEN value unchanged through RegDst.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.movr SrcL, ->{t, u, Rd}"],"defaults":["Every encoded source, immediate, and explicit destination field is required; no field can be omitted.","The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior."],"encoding_class":"standalone-encoded","examples":["c.movr srcl, ->{t, u, rd}"],"exceptions":["Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.","An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR."},"legality":["SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.","Every encoded operand value is assigned; fixed encoding bits must match the canonical form."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"Reg5 source"}],"ordering":["Snapshot any Reg5 source before the destination effect.","Publish the result, then advance TPC by the encoded instruction length."],"standalone_opcode":true,"state_effects":["Return the complete snapshotted SrcL value without conversion.","Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-MOVR","mnemonic":"C.MOVR","summary":"C.MOVR snapshots a Reg5 source and publishes the complete XLEN value unchanged through RegDst.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_MOVR() => ScalarOperation
begin
    return ScalarOperation_C_MOVR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_MOVR() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVR(value: Word)
    => Word
begin
    return MoveScalarValue(value);
end;
// DOC-END: operation
