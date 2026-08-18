// PTO-INSTRUCTION: {"assembly":["hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1"],"block":[],"catalog_indices":[128],"catalog_records":[{"asm":"hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x0000205d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7}],"signedness":"encoding-defined","width":7}],"form_id":"hl_ccatw_48_24a85ea4659c","length_bits":48,"mnemonic":"HL.CCATW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteConcatenatePairW","semantic_summary":"HL.CCATW logically right-shifts {SrcL[31:0], SrcR[31:0]}, sign-extends the low then high 32-bit results, and writes them in order.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1"],"defaults":["SrcL, SrcR, shamt, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.","Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["hl.ccatw a0, a1, 0, ->a2, a3","hl.ccatw t#1, u#1, 64, ->zero, a0","hl.ccatw a0, a1, 127, ->t, t"],"exceptions":["The concatenation shift is total for every shamt and raises no arithmetic exception.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst0":"Encoded zero discards the low result.","RegDst1":"Encoded zero discards the high result.","SrcL":"Encoded zero reads architectural GPR zero.","SrcR":"Encoded zero reads architectural GPR zero.","shamt":"Encoded zero performs no shift."},"legality":["SrcL and SrcR independently use the complete Reg5 source map: GPR0..GPR23, T#1..T#4, and U#1..U#4.","RegDst0 and RegDst1 independently use the common destination map: GPR writes, discard codes, U push, or T push.","shamt 0..127 is fully assigned; values 64..127 produce two zeros."],"memory_effects":["none"],"operands":[{"field":"RegDst0","role":"ordered low-result Reg5 destination or discard"},{"field":"RegDst1","role":"ordered high-result Reg5 destination or discard"},{"field":"SrcL","role":"upper low-word Reg5 source"},{"field":"SrcR","role":"lower low-word Reg5 source"},{"field":"shamt","role":"unsigned seven-bit logical-right shift amount"}],"ordering":["Snapshot both sources before either destination effect; relative source reads do not consume queue entries.","Publish Dst0 first and Dst1 second. Equal GPR destinations retain Dst1; equal queue destinations enqueue Dst0 before Dst1.","After both destination effects, advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Pack SrcL[31:0] above SrcR[31:0]. For shamt 0..63, logically shift the 64-bit value right, sign-extend result bits 31:0 to Dst0 and bits 63:32 to Dst1; for shamt 64..127 both results are zero.","Apply the complete Reg5 destination map independently in Dst0 then Dst1 order; discard destinations have no effect.","No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-CCATW","mnemonic":"HL.CCATW","summary":"HL.CCATW logically right-shifts {SrcL[31:0], SrcR[31:0]}, sign-extends the low then high 32-bit results, and writes them in order.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-CCATW-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.CCATW MUST snapshot SrcL and SrcR, form {SrcL[31:0], SrcR[31:0]}, and
// logically shift the concatenation right by the complete seven-bit shamt.
// Dst0 MUST receive the low result before Dst1 receives the high result.
// Each 32-bit result MUST be sign-extended; shifts 64 through 127 MUST produce two zeros.
// Both sources MUST use the complete non-consuming Reg5 source map and
// both destinations MUST use the common ordered Reg5 destination map.
// Successful execution MUST advance TPC by six bytes and preserve all
// memory, Tile, block, reservation, privilege, numeric-status, and fault state.
// NDF-END: PTO-HL-CCATW-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CCATW() => ScalarOperation
begin
    return ScalarOperation_HL_CCATW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CCATW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePairW;
end;

pure func InstructionContractLowResult_HL_CCATW(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount < 64 then
        var packed: Word = Zeros{PTO_XLEN};
        packed[31:0] = right[31:0];
        packed[63:32] = left[31:0];
        return SignExtend{PTO_XLEN}(
            LSR(packed, shift_amount)[31:0]);
    else
        return Zeros{PTO_XLEN};
    end;
end;

pure func InstructionContractHighResult_HL_CCATW(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount < 64 then
        var packed: Word = Zeros{PTO_XLEN};
        packed[31:0] = right[31:0];
        packed[63:32] = left[31:0];
        return SignExtend{PTO_XLEN}(
            LSR(packed, shift_amount)[63:32]);
    else
        return Zeros{PTO_XLEN};
    end;
end;
// DOC-END: operation
