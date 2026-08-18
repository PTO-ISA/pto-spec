// PTO-INSTRUCTION: {"assembly":["flts.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[104],"catalog_records":[{"asm":"flts.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[{"field":"SrcType","operator":"one-of","values":[0,1]}],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0800205b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"flts_32_c744c874e6a2","length_bits":32,"mnemonic":"FLTS","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingCompare","semantic_summary":"FLTS performs ordered signaling less-than comparison and returns canonical XLEN zero or one.","status":"accepted"}],"classification":["fsu"],"contract":{"block_composition":["none"],"canonical_assembly":["flts.{T} SrcL, SrcR, ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved."],"encoding_class":"standalone-encoded","examples":["flts.fd a0, a1, ->a2","flts.fs t#1, u#1, ->u"],"exceptions":["A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.","Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcType":"Encoded zero selects the 64-bit source carrier; it is not omission."},"legality":["Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.","SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left or sole Reg5 source"},{"field":"SrcR","role":"right Reg5 source"},{"field":"SrcType","role":"source carrier selector"}],"ordering":["Validate every encoded type before the first architectural source read or profile call.","Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.","Accumulate produced flags, publish or discard the destination, and then advance TPC."],"standalone_opcode":true,"state_effects":["FLTS performs ordered signaling less-than comparison and returns canonical XLEN zero or one.","Any NaN returns false. This signaling form records sticky NV for any NaN.","Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.","Successful execution advances TPC by four bytes."]},"depends_on":["PTO-SCALAR-MODEL-FSU-PROFILE"],"id":"PTO-SCALAR-FLTS","mnemonic":"FLTS","summary":"FLTS performs ordered signaling less-than comparison and returns canonical XLEN zero or one.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FLTS()
    => ScalarOperation
begin
    return ScalarOperation_FLTS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FLTS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FLTS(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FLTS(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FLTS(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FLTS()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FLTS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FLTS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FLTS()
    => FloatingCompareOperation
begin
    return FloatingCompare_LT;
end;

pure func InstructionContractSignalingCompare_FLTS()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
