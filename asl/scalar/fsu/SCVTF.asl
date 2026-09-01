// PTO-INSTRUCTION: {"assembly":["scvtf.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[384],"catalog_records":[{"asm":"scvtf.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[{"field":"DstType","operator":"one-of","values":[0,1,2,3]}],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000606b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"scvtf_32_01861bbd5ef2","length_bits":32,"mnemonic":"SCVTF","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","semantic_summary":"SCVTF converts an S64, S32, S16, or S8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["scvtf.{srcT2dstT} SrcL, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType codes 0..3 select S64, S32, S16, and S8 with sign extension.","DstType codes 0..3 select FP64, FP32, FP16, and E4M3; codes 4..31 are reserved."],"encoding_class":"standalone-encoded","examples":["scvtf.sd2fd a0, ->a1","scvtf.sw2fs t#1, ->u"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"DstType":"Encoded zero selects the 64-bit destination carrier; it is not omission.","RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","Every SrcType code is assigned: 0, 1, 2, and 3 select S64, S32, S16, and S8.","DstType codes 0 through 3 select FP64, FP32, FP16, and E4M3; codes 4 through 31 are reserved."],"memory_effects":["none"],"operands":[{"field":"DstType","role":"destination carrier selector"},{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["SCVTF converts an S64, S32, S16, or S8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.","The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.","The pto-v0 reference profile uses the same deterministic conversion rule and flags as TCVT for every shared scalar type pair; scalar conversion supplies saturation disabled.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-SCVTF","mnemonic":"SCVTF","summary":"SCVTF converts an S64, S32, S16, or S8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SCVTF-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// SCVTF MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-SCVTF-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SCVTF()
    => ScalarOperation
begin
    return ScalarOperation_SCVTF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SCVTF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_SCVTF(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_SCVTF(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_SCVTF(encoded);
    return ScalarSignedIntegerSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_SCVTF(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 3;
end;

pure func InstructionContractSourceArity_SCVTF()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_SCVTF()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_SCVTF()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
