// PTO-INSTRUCTION: {"assembly":["hl.setret imm, ->Ra"],"block":[],"catalog_indices":[267],"catalog_records":[{"asm":"hl.setret imm, ->Ra","constraints":[],"encoding":[{"index":0,"mask":"0x00000fff000f","match":"0x00000507000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"imm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"encoding-defined","width":32}],"form_id":"hl_setret_48_302bb793a800","length_bits":48,"mnemonic":"HL.SETRET","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"SetReturnAddress","semantic_summary":"HL.SETRET - Write the architectural return address.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.setret imm, ->Ra"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["hl.setret imm, ->Ra"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"imm32":"Encoded zero supplies numeric zero for the 32-bit immediate value."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"imm32","role":"32-bit immediate value"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["HL.SETRET - Write the architectural return address.","After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SETRET","mnemonic":"HL.SETRET","summary":"HL.SETRET - Write the architectural return address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-SETRET-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.SETRET MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-HL-SETRET-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_HL_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_HL_SETRET(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
// DOC-END: operation
