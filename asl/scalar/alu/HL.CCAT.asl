// PTO-INSTRUCTION: {"assembly":["hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1"],"block":[],"catalog_indices":[127],"catalog_records":[{"asm":"hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x0000105d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7}],"signedness":"encoding-defined","width":7}],"form_id":"hl_ccat_48_a1200d8bf5ac","length_bits":48,"mnemonic":"HL.CCAT","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteConcatenatePair","semantic_summary":"HL.CCAT logically right-shifts {SrcL, SrcR}, writes the low 64-bit result to Dst0, then writes the high result to Dst1.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1"],"defaults":["SrcL, SrcR, shamt, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.","Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["hl.ccat a0, a1, 0, ->a2, a3","hl.ccat t#1, u#1, 64, ->zero, a0","hl.ccat a0, a1, 127, ->t, t"],"exceptions":["The concatenation shift is total for every shamt and raises no arithmetic exception.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst0":"Encoded zero discards the low result.","RegDst1":"Encoded zero discards the high result.","SrcL":"Encoded zero reads architectural GPR zero.","SrcR":"Encoded zero reads architectural GPR zero.","shamt":"Encoded zero performs no shift."},"legality":["SrcL and SrcR independently use the complete Reg5 source map: GPR0..GPR23, T#1..T#4, and U#1..U#4.","RegDst0 and RegDst1 independently use the common destination map: GPR writes, discard codes, U push, or T push.","shamt 0..127 is fully assigned and zero-filling."],"memory_effects":["none"],"operands":[{"field":"RegDst0","role":"ordered low-result Reg5 destination or discard"},{"field":"RegDst1","role":"ordered high-result Reg5 destination or discard"},{"field":"SrcL","role":"upper Reg5 source"},{"field":"SrcR","role":"lower Reg5 source"},{"field":"shamt","role":"unsigned seven-bit logical-right shift amount"}],"ordering":["Snapshot both sources before either destination effect; relative source reads do not consume queue entries.","Publish Dst0 first and Dst1 second. Equal GPR destinations retain Dst1; equal queue destinations enqueue Dst0 before Dst1.","After both destination effects, advance TPC by six bytes."],"standalone_opcode":true,"state_effects":["Form {SrcL, SrcR}, logically shift the 128-bit value right by shamt, publish bits 63:0 to Dst0, then publish bits 127:64 to Dst1.","Apply the complete Reg5 destination map independently in Dst0 then Dst1 order; discard destinations have no effect.","No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-CCAT","mnemonic":"HL.CCAT","summary":"HL.CCAT logically right-shifts {SrcL, SrcR}, writes the low 64-bit result to Dst0, then writes the high result to Dst1.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-CCAT-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.CCAT MUST snapshot SrcL and SrcR, form {SrcL, SrcR}, and
// logically shift the concatenation right by the complete seven-bit shamt.
// Dst0 MUST receive the low result before Dst1 receives the high result.
// All shifts 0 through 127 MUST be assigned and zero-filling.
// Both sources MUST use the complete non-consuming Reg5 source map and
// both destinations MUST use the common ordered Reg5 destination map.
// Successful execution MUST advance TPC by six bytes and preserve all
// memory, Tile, block, reservation, privilege, numeric-status, and fault state.
// NDF-END: PTO-HL-CCAT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CCAT() => ScalarOperation
begin
    return ScalarOperation_HL_CCAT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CCAT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePair;
end;

pure func InstructionContractLowResult_HL_CCAT(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount == 0 then
        return right;
    elsif shift_amount < 64 then
        return LSR(right, shift_amount) OR
            LSL(left, 64 - shift_amount);
    else
        return LSR(left, shift_amount - 64);
    end;
end;

pure func InstructionContractHighResult_HL_CCAT(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount == 0 then
        return left;
    elsif shift_amount < 64 then
        return LSR(left, shift_amount);
    else
        return Zeros{PTO_XLEN};
    end;
end;
// DOC-END: operation
