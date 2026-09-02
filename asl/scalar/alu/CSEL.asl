// PTO-INSTRUCTION: {"assembly":["csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}"],"block":[],"catalog_indices":[71],"catalog_records":[{"asm":"csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000077","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcP","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"csel_32_ba77cbad3c99","length_bits":32,"mnemonic":"CSEL","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarConditionalSelect","semantic_summary":"CSEL snapshots three Reg5 sources, selects SrcL for a nonzero predicate or its optionally negated SrcR for zero, and publishes through the common scalar destination map.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}"],"defaults":["SrcP, SrcL, SrcR, SrcRType, and RegDst are required encoded fields; no field can be omitted.","Assembly without .neg uses the canonical unmodified alias selected by the assembler. Raw SrcRType codes 00, 01, and 10 are assigned unmodified aliases; raw code 11 is .neg."],"encoding_class":"standalone-encoded","examples":["csel a0, a1, a2, ->a3","csel t#1, u#1, a0.neg, ->u","csel zero, a0, a1, ->zero"],"exceptions":["An unavailable selected T/U queue source raises Fault_IllegalInstruction before the destination effect and before TPC advances, including a source not selected by the predicate outcome.","CSEL raises no arithmetic, memory, alignment, permission, or control-flow exception."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcP":"Encoded zero reads the architectural zero GPR and therefore selects the false value.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero is an assigned unmodified false-source alias."},"legality":["SrcP, SrcL, and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","All four SrcRType values are assigned. Codes 00, 01, and 10 leave SrcR unchanged; code 11 negates the complete XLEN value modulo 2^PTO_XLEN.","RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T."],"memory_effects":["none"],"operands":[{"field":"SrcP","role":"Reg5 predicate source"},{"field":"SrcL","role":"Reg5 true-value source"},{"field":"SrcR","role":"Reg5 false-value source"},{"field":"SrcRType","role":"CSEL-specific false-source modifier selector"},{"field":"RegDst","role":"Reg5 destination or discard"}],"ordering":["Read all three Reg5 sources eagerly and non-consumingly before the destination write, even when the predicate outcome does not select one value.","Publish the selected value, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Snapshot SrcP, SrcL, and SrcR before any destination effect. Only an all-zero SrcP is false; every nonzero bit pattern is true.","For a true predicate publish the complete snapshotted SrcL. For a false predicate publish the complete snapshotted SrcR after the CSEL-specific raw modifier; negation wraps modulo 2^PTO_XLEN and does not fault.","No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-CSEL","mnemonic":"CSEL","summary":"CSEL snapshots three Reg5 sources, selects SrcL for a nonzero predicate or its optionally negated SrcR for zero, and publishes through the common scalar destination map.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CSEL()
    => ScalarOperation
begin
    return ScalarOperation_CSEL;
end;

pure func InstructionContractRightModifier_CSEL(encoded: bits(2))
    => ScalarRightModifier
begin
    return DecodeScalarSelectRightModifier(encoded);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CSEL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarConditionalSelect;
end;

pure func InstructionContractFalseValue_CSEL(
    right: Word,
    encoded_modifier: bits(2))
    => Word
begin
    let modifier = InstructionContractRightModifier_CSEL(encoded_modifier);
    return ApplySelectModifier(right, modifier);
end;

pure func InstructionContractResult_CSEL(
    predicate: Word,
    selected_true: Word,
    selected_false: Word,
    encoded_modifier: bits(2))
    => Word
begin
    let prepared_false = InstructionContractFalseValue_CSEL(
        selected_false,
        encoded_modifier);
    return ScalarConditionalSelect(
        predicate,
        selected_true,
        prepared_false);
end;
// DOC-END: operation
