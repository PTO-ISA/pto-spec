// PTO-INSTRUCTION: {"assembly":["C.BSTART COND,  label","C.BSTART DIRECT, label"],"block":[],"catalog_indices":[54,55],"catalog_records":[{"asm":"C.BSTART COND,  label","constraints":[],"encoding":[{"index":0,"mask":"0x000f","match":"0x0004","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm12","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"c_bstart_16_c4e238a9227a","length_bits":16,"mnemonic":"C.BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts a compressed standard block with a PC-relative direct or conditional candidate target.","status":"accepted"},{"asm":"C.BSTART DIRECT, label","constraints":[],"encoding":[{"index":0,"mask":"0x000f","match":"0x0002","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm12","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"c_bstart_16_f833d2a4753c","length_bits":16,"mnemonic":"C.BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts a compressed standard block with a PC-relative direct or conditional candidate target.","status":"accepted"}],"classification":["encoding"],"contract":{"block_composition":["After any active predecessor block commits successfully, C.BSTART opens one Standard block. Header commands execute sequentially until BSTOP or the next BSTART commits the new BARG continuation."],"canonical_assembly":["C.BSTART COND,  label","C.BSTART DIRECT, label"],"defaults":["simm12 is always encoded. Encoded zero computes the candidate target P and is not omission.","The conditional form initializes BARG.TAKEN to false; the direct form initializes it to true."],"encoding_class":"standalone-encoded","examples":["C.BSTART DIRECT, label","C.BSTART COND, label"],"exceptions":["An odd computed candidate target raises Fault_InstructionPC before predecessor retirement or new BARG effects.","If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed."],"field_contracts":{},"field_zero_meanings":{"simm12":"Encoded zero supplies a zero displacement or zero immediate value."},"legality":["Exactly the low-nibble forms 0x2 (DIRECT) and 0x4 (COND) are assigned to C.BSTART.","simm12 accepts every signed 12-bit value and computes P + (SignExtend(simm12) << 1)."],"memory_effects":["none"],"operands":[{"field":"simm12","role":"12-bit signed bundle target displacement"}],"ordering":["Decode, target calculation, and target alignment checks precede predecessor retirement. New BARG state is installed only after successful retirement."],"standalone_opcode":true,"state_effects":["Installs BARG.BPC=P, BlockType=STD, BPCN=the computed candidate target, and TYPE=DIRECT or COND.","DIRECT installs TAKEN=1; COND installs TAKEN=0 until an applicable SETC operation resolves it. The candidate continuation is selected only at BSTOP or the next BSTART."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-C-BSTART","mnemonic":"C.BSTART","summary":"Starts a compressed standard block with a PC-relative direct or conditional candidate target.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-C-BSTART-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// C.BSTART MUST open one standard block with either a direct or conditional
// transfer. Its signed displacement MUST be shifted left by one and added to
// the C.BSTART address before the retiring block is committed.
// NDF-END: PTO-C-BSTART-CONTROL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_16_c4e238a9227a) ||
           (operation == CommandOperation_c_bstart_16_f833d2a4753c);
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractTarget_C_BSTART(
    instruction_pc: Word,
    displacement: bits(12))
    => Word
begin
    return instruction_pc +
        LSL(SignExtend{PTO_XLEN}(displacement), 1);
end;

readonly func InstructionContractHandler_C_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
