// PTO-INSTRUCTION: {"assembly":["setret uimm, ->Ra"],"block":[],"catalog_indices":[415],"catalog_records":[{"asm":"setret uimm, ->Ra","constraints":[],"encoding":[{"index":0,"mask":"0x00000fff","match":"0x00000507","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"setret_32_72003dcf3b59","length_bits":32,"mnemonic":"SETRET","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"SetReturnAddress","semantic_summary":"SETRET - Write the architectural return address.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["setret uimm, ->Ra"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["setret uimm, ->Ra"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"imm20":"Encoded zero supplies numeric zero for the 20-bit immediate value."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"imm20","role":"20-bit immediate value"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["SETRET - Write the architectural return address.","After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SETRET","mnemonic":"SETRET","summary":"SETRET - Write the architectural return address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SETRET-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0026, ADR-0027.
// SETRET MUST compute pre-increment TPC plus the zero-extended unsigned
// halfword-scaled immediate, update architectural ra and retained return state
// atomically, then retire sequentially without installing a direct branch target.
// NDF-END: PTO-SETRET-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETRET() => ScalarOperation
begin
    return ScalarOperation_SETRET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_SETRET(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
// DOC-END: operation
