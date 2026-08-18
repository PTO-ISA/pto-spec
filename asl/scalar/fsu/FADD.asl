// PTO-INSTRUCTION: {"assembly":["fadd.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[88],"catalog_records":[{"asm":"fadd.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[{"field":"SrcType","operator":"one-of","values":[0,1]}],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000004b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fadd_32_b78b658e6740","length_bits":32,"mnemonic":"FADD","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingBinary","semantic_summary":"FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["fadd.{T} SrcL, SrcR, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved."],"encoding_class":"standalone-encoded","examples":["fadd.fd a0, a1, ->a2","fadd.fs t#1, u#1, ->u"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcR","role":"right Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.","The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.","For pto-v0, add the normalized carriers modulo the selected width and return zero flags. This executable reference behavior is not target floating-point conformance.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-FADD","mnemonic":"FADD","summary":"FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FADD()
    => ScalarOperation
begin
    return ScalarOperation_FADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FADD(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FADD(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FADD(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FADD()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FADD()
    => FloatingBinaryOperation
begin
    return FloatingBinary_ADD;
end;
// DOC-END: operation
