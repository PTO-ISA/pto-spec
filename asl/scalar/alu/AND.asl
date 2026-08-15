// PTO-INSTRUCTION: {"assembly":["and SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}"],"block":[],"catalog_indices":[7],"catalog_records":[{"asm":"and SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002005","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"and_32_b6a903a3ec94","length_bits":32,"mnemonic":"AND","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","semantic_summary":"AND applies the selected right-source transformation before its encoded logical left shift, performs bitwise conjunction, and publishes the PTO_XLEN result.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["none"],"canonical_assembly":["and SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}"],"defaults":["SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.","SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .not, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.","Encoded shamt zero performs no shift; every value from 0 through 31 is assigned."],"encoding_class":"standalone-encoded","examples":["and a0, a1, ->a2","and t#1, u#1.not<<1, ->u","and zero, a0.sw, ->zero"],"exceptions":["AND raises no arithmetic exception; transformed or shifted-out bits are discarded at PTO_XLEN width.","A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the result.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero selects .sw and sign-extends SrcR[31:0].","shamt":"Encoded zero performs no shift."},"legality":["SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.","RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.","All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; AND uses .not.","Every five-bit shamt value from 0 through 31 is legal."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination or discard"},{"field":"SrcL","role":"left Reg5 source"},{"field":"SrcR","role":"right Reg5 source"},{"field":"SrcRType","role":"right-source transformation selector"},{"field":"shamt","role":"post-transformation logical-left-shift amount"}],"ordering":["Snapshot both sources before the destination effect so duplicate sources, destination aliases, and queue publication use pre-instruction values.","Publish the result, then advance TPC by four bytes."],"standalone_opcode":true,"state_effects":["Transform SrcR, perform the logical left shift, and compute the PTO_XLEN bitwise conjunction with SrcL.","Apply the selected SrcRType transformation before the logical left shift. The transformation and shift affect SrcR only; SrcL is unchanged before the final operation.","Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.","No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-AND","mnemonic":"AND","summary":"AND applies the selected right-source transformation before its encoded logical left shift, performs bitwise conjunction, and publishes the PTO_XLEN result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_AND()
    => ScalarOperation
begin
    return ScalarOperation_AND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_AND()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_AND(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_AND(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_AND(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_AND(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_AND(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_AND, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_AND()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_AND()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
