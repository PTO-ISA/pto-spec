// PTO-INSTRUCTION: {"assembly":["BSTART.CALL <br_label>, <rt_label>, ->ra"],"block":[],"catalog_indices":[15],"catalog_records":[{"asm":"BSTART.CALL <br_label>, <rt_label>, ->ra","constraints":[],"encoding":[{"index":0,"mask":"0xf83f000f","match":"0x50160002","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm12","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":12}],"signedness":"signed","width":12},{"name":"uimm5","pieces":[{"instruction_lsb":22,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"bstart_call_32_9404418d1ae5","length_bits":32,"mnemonic":"BSTART.CALL","semantic_family":"BBD","semantic_group":"BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Atomically retires the old block, installs a direct-call BARG, and writes the independent return target to ra.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["none"],"canonical_assembly":["BSTART.CALL <br_label>, <rt_label>, ->ra"],"defaults":["simm12 and uimm5 are both present; encoded zero is a real zero displacement for that field."],"encoding_class":"standalone-encoded","examples":["BSTART.CALL <br_label>, <rt_label>, ->ra"],"exceptions":["An odd call target raises Fault_InstructionPC before retiring-block effects.","Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG."],"field_contracts":{},"field_zero_meanings":{"simm12":"Encoded zero supplies a zero displacement or zero immediate value.","uimm5":"Encoded zero supplies a zero displacement or zero immediate value."},"legality":["All bit patterns not excluded by the form decode are assigned by this instruction contract."],"memory_effects":["Any memory effects of the retiring block complete before the call BARG and ra are published; BSTART.CALL itself performs no memory access."],"operands":[{"field":"simm12","role":"12-bit signed bundle target displacement"},{"field":"uimm5","role":"unsigned return-address displacement"}],"ordering":["Validate both targets, successfully commit the retiring block, then atomically install the new STD BARG and write ra."],"standalone_opcode":true,"state_effects":["Installs BARG.BPC=P, BlockType=STD, BPCN=call_target, TYPE=DIRECT, TAKEN=1, and writes return_target to ra.","The call target is selected only when the new block later commits."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-CALL","mnemonic":"BSTART.CALL","summary":"Atomically retires the old block, installs a direct-call BARG, and writes the independent return target to ra.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-CALL-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.CALL MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-BSTART-CALL-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_call_32_9404418d1ae5);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_CALL()
    => BundleTransfer
begin
    return BundleTransfer_Call;
end;

pure func InstructionContractWritesReturnAddress_BSTART_CALL()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
