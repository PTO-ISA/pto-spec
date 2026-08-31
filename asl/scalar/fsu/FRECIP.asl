// PTO-INSTRUCTION: {"assembly":["frecip.{T} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[114],"catalog_records":[{"asm":"frecip.{T} SrcL, ->{t, u, Rd}","constraints":[{"field":"SrcType","operator":"one-of","values":[0,1]}],"encoding":[{"index":0,"mask":"0xf9f0707f","match":"0x0000207b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"frecip_32_3d51f4f727ea","length_bits":32,"mnemonic":"FRECIP","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingUnary","semantic_summary":"FRECIP applies the active numeric profile reciprocal operation to the selected FP64 or FP32 carrier.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["frecip.{T} SrcL, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved."],"encoding_class":"standalone-encoded","examples":["frecip.fd a0, ->a1","frecip.fs t#1, ->t"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["FRECIP applies the active numeric profile reciprocal operation to the selected FP64 or FP32 carrier.","The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.","For pto-v0 finite FP32 and FP64 carriers, execute the declared operation through the reference finite floating profile using the selected rounding mode and publish the returned NV, DZ, OF, UF, and NX flags.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-FRECIP","mnemonic":"FRECIP","summary":"FRECIP applies the active numeric profile reciprocal operation to the selected FP64 or FP32 carrier.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FRECIP()
    => ScalarOperation
begin
    return ScalarOperation_FRECIP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FRECIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FRECIP(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FRECIP(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FRECIP(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FRECIP()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FRECIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FRECIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUnaryOperation_FRECIP()
    => FloatingUnaryOperation
begin
    return FloatingUnary_RECIP;
end;
// DOC-END: operation
