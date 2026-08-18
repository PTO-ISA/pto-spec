// PTO-INSTRUCTION: {"assembly":["BSTART.ICALL <rt_label>, ->ra"],"block":[],"catalog_indices":[16],"catalog_records":[{"asm":"BSTART.ICALL <rt_label>, ->ra","constraints":[],"encoding":[{"index":0,"mask":"0xf83fffff","match":"0x50166001","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"uimm5","pieces":[{"instruction_lsb":22,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"bstart_icall_32_50166001","length_bits":32,"mnemonic":"BSTART.ICALL","semantic_family":"BBD","semantic_group":"BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Atomically retires the old block, snapshots its BARG.BPCN into a new indirect-call BARG, and writes the independent return target to ra.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.ICALL retires one active Standard or Floating block whose BARG.BPCN supplies the call target, then atomically opens a new Standard indirect-call block and writes ra."],"canonical_assembly":["BSTART.ICALL <rt_label>, ->ra"],"defaults":["Encoded uimm5 zero is a real zero displacement from the embedded C.SETRET halfword."],"encoding_class":"standalone-encoded","examples":["BSTART.ICALL <rt_label>, ->ra"],"exceptions":["No active retiring Standard or Floating block raises Fault_BundleControl before target or return-address effects.","An odd retiring BARG.BPCN raises Fault_InstructionPC before retiring-block effects.","Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG."],"field_contracts":{},"field_zero_meanings":{"uimm5":"Encoded zero selects P+2 as the return target."},"legality":["This fused form is the only accepted indirect-call spelling; bare BSTART.* ICALL forms are deleted.","The retiring block must be Standard or Floating because System BARG has no selecting BPCN."],"memory_effects":["Any memory effects of the retiring block complete before the indirect-call BARG and ra are published; BSTART.ICALL itself performs no memory access."],"operands":[{"field":"uimm5","role":"unsigned return-address displacement from the embedded high halfword"}],"ordering":["Snapshot and validate retiring BARG.BPCN, successfully commit the retiring block, then atomically install the new STD BARG and write ra."],"standalone_opcode":true,"state_effects":["Installs BARG.BPC=P, BlockType=STD, BPCN=the retiring BARG.BPCN snapshot, TYPE=ICALL, TAKEN=1, and writes return_target to ra.","The indirect target is selected only when the new block later commits."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-ICALL","mnemonic":"BSTART.ICALL","summary":"Atomically retires the old block, snapshots its BARG.BPCN into a new indirect-call BARG, and writes the independent return target to ra.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-ICALL-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.ICALL MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-BSTART-ICALL-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_ICALL(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_bstart_icall_32_50166001;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_ICALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_ICALL()
    => BundleTransfer
begin
    return BundleTransfer_IndirectCall;
end;

pure func InstructionContractWritesReturnAddress_BSTART_ICALL()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
