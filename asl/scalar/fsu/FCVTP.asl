// PTO-INSTRUCTION: {"assembly":["fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[101],"catalog_records":[{"asm":"fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[{"field":"SrcType","operator":"one-of","values":[0,1]},{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]}],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000406b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fcvtp_32_84354a7aa6b1","length_bits":32,"mnemonic":"FCVTP","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","semantic_summary":"FCVTP converts a selected FP64 or FP32 carrier to integer carrier code 0 through 14 with fixed round-up mode.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved.","DstType codes 0..14 are assigned carrier widths and codes 15..31 are reserved."],"encoding_class":"standalone-encoded","examples":["fcvtp.fd2sd a0, ->a1","fcvtp.fs2sw t#1, ->u"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"DstType":"Encoded zero selects the 64-bit destination carrier; it is not omission.","RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.","DstType codes 0 through 14 are assigned; codes 15 through 31 are reserved."],"memory_effects":["none"],"operands":[{"field":"DstType","role":"destination carrier selector"},{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["FCVTP converts a selected FP64 or FP32 carrier to integer carrier code 0 through 14 with fixed round-up mode.","The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.","For pto-v0, preserve the normalized source bits, retain the selected integer carrier width, and return zero flags. This executable reference behavior is not target floating-point conformance.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-FCVTP","mnemonic":"FCVTP","summary":"FCVTP converts a selected FP64 or FP32 carrier to integer carrier code 0 through 14 with fixed round-up mode.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FCVTP()
    => ScalarOperation
begin
    return ScalarOperation_FCVTP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FCVTP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVTP(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FCVTP(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVTP(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVTP(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 14;
end;

pure func InstructionContractSourceArity_FCVTP()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVTP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVTP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractFixedRounding_FCVTP()
    => NumericRoundingMode
begin
    return NumericRound_RTP;
end;
// DOC-END: operation
