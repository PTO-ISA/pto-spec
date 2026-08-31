// PTO-INSTRUCTION: {"assembly":["ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[461],"catalog_records":[{"asm":"ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[{"field":"SrcType","operator":"one-of","values":[0,1]},{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]}],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000706b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"ucvtf_32_987f4e019c32","length_bits":32,"mnemonic":"UCVTF","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","semantic_summary":"UCVTF converts an unsigned 64-bit or zero-extended unsigned 32-bit source to floating carrier code 0 through 14 through the active numeric profile.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType=0 selects unsigned 64-bit and SrcType=1 selects unsigned 32-bit with zero extension. SrcType=2 and SrcType=3 are reserved.","DstType codes 0..14 are assigned carrier widths and codes 15..31 are reserved."],"encoding_class":"standalone-encoded","examples":["ucvtf.ud2fd a0, ->a1","ucvtf.uw2fs t#1, ->u"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"DstType":"Encoded zero selects the 64-bit destination carrier; it is not omission.","RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.","DstType codes 0 through 14 are assigned; codes 15 through 31 are reserved."],"memory_effects":["none"],"operands":[{"field":"DstType","role":"destination carrier selector"},{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["UCVTF converts an unsigned 64-bit or zero-extended unsigned 32-bit source to floating carrier code 0 through 14 through the active numeric profile.","The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.","For pto-v0 finite FP32 and FP64 carriers, execute the declared operation through the reference finite floating profile using the selected rounding mode and publish the returned NV, DZ, OF, UF, and NX flags.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-UCVTF","mnemonic":"UCVTF","summary":"UCVTF converts an unsigned 64-bit or zero-extended unsigned 32-bit source to floating carrier code 0 through 14 through the active numeric profile.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-UCVTF-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// UCVTF MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-UCVTF-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_UCVTF()
    => ScalarOperation
begin
    return ScalarOperation_UCVTF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_UCVTF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_UCVTF(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_UCVTF(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_UCVTF(encoded);
    return ScalarUnsignedIntegerSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_UCVTF(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 14;
end;

pure func InstructionContractSourceArity_UCVTF()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_UCVTF()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_UCVTF()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
