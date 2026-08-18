// PTO-INSTRUCTION: {"assembly":["addtpc simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[5],"catalog_records":[{"asm":"addtpc simm, ->{t, u, Rd}","constraints":[{"field":"RegDst","operator":"not-equal","value":10}],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000007","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"addtpc_32_e5aa0f0abca3","length_bits":32,"mnemonic":"ADDTPC","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"AddToPC","semantic_summary":"ADDTPC - Add a signed 4 KiB page displacement to the current TPC.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["addtpc simm, ->{t, u, Rd}"],"defaults":["The imm20 field is sign-extended and scaled by 4096 bytes; encoded zero contributes a zero page displacement and produces the current instruction TPC.","The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["addtpc simm, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","imm20":"Encoded zero contributes a zero page displacement and produces the current instruction TPC."},"legality":["addtpc_32_e5aa0f0abca3.RegDst excludes 10; the excluded encoding is reserved."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"imm20","role":"signed 20-bit 4 KiB page displacement"}],"ordering":["Read the current instruction TPC before computing the wrapping XLEN result.","After the destination effect, the scalar dispatch boundary advances TPC by four bytes."],"standalone_opcode":true,"state_effects":["ADDTPC writes TPC + (SignExtend(imm20) << 12), wrapping at XLEN, through the selected Reg5 destination.","The instruction does not install a control-flow target and does not directly modify TPC."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-ADDTPC","mnemonic":"ADDTPC","summary":"ADDTPC - Add a signed 4 KiB page displacement to the current TPC.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-ADDTPC-PAGE-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// ADDTPC MUST add SignExtend(imm20) shifted left by twelve to the current
// instruction TPC, MUST wrap at XLEN, and MUST write only through the selected
// Reg5 destination. It MUST NOT install a control-flow target or directly
// advance TPC. Encoded immediate zero MUST produce the current TPC.
// NDF-END: PTO-ADDTPC-PAGE-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_ADDTPC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractImmediateWidth_ADDTPC()
    => integer {20}
begin
    return 20;
end;

pure func InstructionContractImmediateIsSigned_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPageShift_ADDTPC()
    => integer {12}
begin
    return 12;
end;

pure func InstructionContractWritesTPC_ADDTPC()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractTarget_ADDTPC(
    base: Word,
    page_offset: Word)
    => Word
begin
    return base + LSL(page_offset, 12);
end;
// DOC-END: operation
