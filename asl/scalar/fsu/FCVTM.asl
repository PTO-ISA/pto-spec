// PTO-INSTRUCTION: {"assembly":["fcvtm.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[91],"catalog_records":[{"asm":"fcvtm.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7]}],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000206b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fcvtm_32_8801f1562870","length_bits":32,"mnemonic":"FCVTM","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","semantic_summary":"FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["fcvtm.{srcT2dstT} SrcL, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType codes 0..3 select FP64, FP32, FP16, and E4M3; every code is assigned.","DstType raw codes 0..3 select UD/UW/UH/UB, raw codes 4..7 select SD/SW/SH/SB, and raw codes 8..31 are reserved."],"encoding_class":"standalone-encoded","examples":["fcvtm.fd2sd a0, ->a1","fcvtm.fs2sw t#1, ->u"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"DstType":"Encoded zero selects the 64-bit destination carrier; it is not omission.","RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","Every SrcType code is assigned: 0, 1, 2, and 3 select FP64, FP32, FP16, and E4M3.","DstType raw codes 0 through 3 map to unsigned 64-, 32-, 16-, and 8-bit results; raw codes 4 through 7 map to the corresponding signed results; raw codes 8 through 31 are reserved."],"memory_effects":["none"],"operands":[{"field":"DstType","role":"destination carrier selector"},{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.","The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.","The pto-v0 reference profile uses the same deterministic conversion rule and flags as TCVT for every shared scalar type pair; scalar conversion supplies saturation disabled.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-FCVTM","mnemonic":"FCVTM","summary":"FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-FCVTM-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// FCVTM MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-FCVTM-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FCVTM()
    => ScalarOperation
begin
    return ScalarOperation_FCVTM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FCVTM()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVTM(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_FCVTM(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVTM(encoded);
    return ScalarConvertFloatingTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVTM(encoded: bits(5))
    => boolean
begin
    return ScalarFPToIntegerDestinationRawLegal(encoded);
end;

pure func InstructionContractDestinationCarrier_FCVTM(encoded: bits(5))
    => bits(5)
begin
    assert InstructionContractDestinationTypeLegal_FCVTM(encoded);
    return ScalarFPToIntegerDestinationTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FCVTM()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVTM()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVTM()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractFixedRounding_FCVTM()
    => NumericRoundingMode
begin
    return NumericRound_RTM;
end;
// DOC-END: operation
