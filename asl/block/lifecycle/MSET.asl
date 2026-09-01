// PTO-INSTRUCTION: {"assembly":["MSET [RegSrc0=Destination, RegSrc1=FillByte, RegSrc2=LengthBytes]"],"block":[],"catalog_indices":[70],"catalog_records":[{"asm":"MSET [RegSrc0=Destination, RegSrc1=FillByte, RegSrc2=LengthBytes]","constraints":[{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00001031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mset_32_0b932f291932","length_bits":32,"mnemonic":"MSET","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteMemorySet","semantic_summary":"Fills a complete unsigned XLEN byte range with the low byte of an absolute GPR after complete access preflight.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["MSET is a standalone template instruction and does not consume a BSTART/BSTOP body."],"canonical_assembly":["MSET [Destination, FillByte, LengthBytes]"],"defaults":["All three absolute GPR fields are encoded and required; encoded zero reads the architectural zero GPR.","LengthBytes is the complete unsigned XLEN value. Zero is a successful zero-length command; every nonzero value names that many bytes and no fixed instruction-length ceiling applies."],"encoding_class":"standalone-encoded","examples":["MSET [a0, a1, a2]","MSET [zero, zero, zero]"],"exceptions":["Selectors 24 through 31 in any source field raise Fault_IllegalInstruction before register, memory, reservation, last-command, or TPC effects.","A nonzero destination interval that wraps modulo 2^PTO_XLEN raises Fault_IllegalInstruction before memory or last-command effects.","A destination access fault is reported before the first store and leaves the complete range unchanged."],"field_contracts":{},"field_zero_meanings":{"RegSrc0":"Encoded zero supplies destination address zero.","RegSrc1":"Encoded zero supplies fill byte zero.","RegSrc2":"Encoded zero supplies zero length."},"legality":["RegSrc0, RegSrc1, and RegSrc2 each accept only absolute GPR codes 0 through 23; 24 through 31 are reserved.","The complete unsigned LengthBytes value is assigned and is never truncated to a smaller surrogate; every nonzero destination interval must be non-wrapping.","Every byte address is naturally aligned and the full destination range must pass write access preflight before effects."],"memory_effects":["For nonzero length, probe the complete destination byte range before the first store, then write FillByte[7:0] to every byte in increasing address order.","A successful nonzero fill invalidates an overlapping local load-reservation granule; zero length performs no memory or reservation access."],"operands":[{"field":"RegSrc0","role":"absolute GPR containing destination byte address"},{"field":"RegSrc1","role":"absolute GPR whose low eight bits are replicated"},{"field":"RegSrc2","role":"absolute GPR containing complete unsigned byte length"}],"ordering":["Snapshot all three GPR values before access validation and memory effects.","Successful completion records the command state and then advances TPC by four bytes."],"standalone_opcode":true,"state_effects":["After successful zero or nonzero completion, set _LastMemoryCommandAddress to Destination and _LastMemoryCommandSize to LengthBytes.","On every fault, preserve memory, reservation state, last-command state, and TPC."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-MSET","mnemonic":"MSET","summary":"Fills an arbitrary complete-XLEN byte range from three absolute GPR operands after complete access preflight.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BLOCK-MSET-FILL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// MSET MUST read only absolute GPR codes 0..23 and MUST consume the complete
// unsigned XLEN length without imposing a fixed instruction-length ceiling.
// A nonzero destination interval MUST be non-wrapping. The complete range
// MUST be preflighted before RegSrc1[7:0] is replicated to every byte.
// NDF-END: PTO-BLOCK-MSET-FILL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_MSET(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_mset_32_0b932f291932;
end;

pure func InstructionContractAbsoluteGPRSelectorLegal_MSET(
    selector: Reg5Selector) => boolean
begin
    return selector <= 23;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MSET() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemorySet;
end;

pure func InstructionContractMemoryStepRestartable_MSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAcceptsCompleteXLENLength_MSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MSET()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
