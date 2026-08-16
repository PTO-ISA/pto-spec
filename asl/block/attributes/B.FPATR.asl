// PTO-INSTRUCTION: {"assembly":["B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn"],"block":[],"catalog_indices":[73],"catalog_records":[{"asm":"B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn","constraints":[{"field":"PreQuantMode","operator":"one-of","values":[0,1,2,3,4,5,12,13,16,17,18,19,20,23,24,25,26,27,28,32,33,34,35,36,37,38,39]},{"field":"ReluMode","operator":"one-of","values":[0,1,2,3]},{"field":"GroupNCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9]},{"field":"RowMaxEn","operator":"one-of","values":[0,1]},{"field":"GroupMaxEn","operator":"one-of","values":[0,1]},{"field":"RowMaxInit","operator":"one-of","values":[0,1]},{"field":"MaxAbsEn","operator":"one-of","values":[0,1]},{"field":"Func","operator":"one-of","values":[2]},{"field":"ElementWiseEn","operator":"one-of","values":[0]},{"field":"Reserved","operator":"one-of","values":[0]},{"field":"Opc1","operator":"one-of","values":[2]},{"field":"Opcode","operator":"one-of","values":[1]},{"field":"W","operator":"one-of","values":[1]}],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00002023","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"PreQuantMode","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"ReluMode","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"GroupNCode","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"RowMaxEn","pieces":[{"instruction_lsb":18,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"GroupMaxEn","pieces":[{"instruction_lsb":17,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"RowMaxInit","pieces":[{"instruction_lsb":16,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"MaxAbsEn","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"Func","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"ElementWiseEn","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"Reserved","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"Opc1","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"Opcode","pieces":[{"instruction_lsb":1,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"W","pieces":[{"instruction_lsb":0,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"b_fpatr_32_4f2db11e8e8a","length_bits":32,"mnemonic":"B.FPATR","semantic_family":"CMD","semantic_group":"Bundle Fixed-Point PostProcess Attribute","semantic_handler":"SetBundleFixedPointAttributes","semantic_summary":"Latches complete-bundle matrix post-processing mode, reduction enables, and fixed-point descriptor controls.","status":"accepted"}],"classification":["attributes"],"mnemonic":"B.FPATR","summary":"Latches complete-bundle matrix post-processing mode, reduction enables, and fixed-point descriptor controls.","surface":"block","id":"PTO-BLOCK-B-FPATR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES"],"contract":{"block_composition":["Required exactly once in a CUBE Matrix block after BSTART and before scalar or tile bindings and the first body instruction.","The complete block schema places mathematical Local sources first, then optional RowMaxIn, vector pre-quantization, and vector PReLU sources; Local destinations are D, optional RowMaxOut, then optional GroupMaxOut.","Scalar pre-quantization and LReLU/PReLU parameters use the dense B.IOR schema; LReLU-only consumes RegSrc0."],"canonical_assembly":["B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn"],"defaults":["Encoded PreQuantMode=0 and ReluMode=0 disable pre-quantization and activation. GroupNCode=0 selects no group maximum. All four enable bits default to disabled.","Omitting B.FPATR is not a default for a CUBE Matrix block: complete-bundle preflight rejects the missing command before allocation or effects."],"encoding_class":"standalone-encoded","examples":["B.FPATR None, None, 0, 0, 0, 0, 0","B.FPATR S8Vector, LReLU, 2, 1, 1, 1, 1"],"exceptions":["Missing, duplicate, or non-CUBE-Matrix use raises Fault_BundleControl before operand consumption, allocation, payload, or destination effects.","Reserved field values, inconsistent reduction enables, invalid B.DATR conversion controls, malformed operand streams, illegal aliases, or invalid derived shapes raise Fault_TileLegality before effects.","Fixed-bit mismatch does not decode as B.FPATR and is rejected by normal command decoding before this handler executes."],"field_contracts":{},"field_zero_meanings":{"PreQuantMode":"No pre-quantization; the Matrix accumulation result remains FP32.","ReluMode":"No activation.","GroupNCode":"No group maximum; GroupMaxEn must also be zero.","RowMaxEn":"No RowMax input or output.","GroupMaxEn":"No GroupMax output.","RowMaxInit":"Do not initialize RowMax from RowMaxIn.","MaxAbsEn":"Use signed maximum rather than maximum absolute value for enabled reductions.","ElementWiseEn":"Fixed zero selects complete-bundle Matrix post-processing.","Reserved":"Fixed zero; every nonzero encoding is reserved."},"legality":["PreQuantMode accepts exactly codes 0..5, 12..13, 16..20, 23..28, and 32..39; all other six-bit codes are reserved.","ReluMode codes 0..3 select None, ReLU, scalar LReLU/PReLU, and vector PReLU; codes 4..7 are reserved.","GroupNCode codes 0..9 select 0, 8, 16, 32, 48, 64, 80, 96, 112, and 128 columns; codes 10..15 are reserved.","RowMaxInit requires RowMaxEn. GroupMaxEn requires nonzero GroupNCode and nonzero GroupNCode requires GroupMaxEn. MaxAbsEn requires RowMaxEn or GroupMaxEn.","Func=2, ElementWiseEn=0, Reserved=0, Opc1=2, Opcode=1, and W=1 are fixed encoding discriminators.","Matrix B.DATR supplies only destination conversion controls when B.FPATR is present: None requires RMode=NONE and Sat=0; shift modes require RMode=NONE; accepted non-None modes otherwise retain the complete rounding selector and independent saturation control.","The derived scalar/vector parameter count, Local source count, and Local destination count must fit the complete-bundle schema without duplicate destinations or illegal source/destination aliases."],"memory_effects":["none"],"operands":[{"field":"PreQuantMode","role":"closed Matrix destination pre-quantization and output-type selector"},{"field":"ReluMode","role":"post-conversion activation selector"},{"field":"GroupNCode","role":"group maximum column-count selector"},{"field":"RowMaxEn","role":"row maximum input/output enable"},{"field":"GroupMaxEn","role":"group maximum output enable"},{"field":"RowMaxInit","role":"row maximum initialization from RowMaxIn enable"},{"field":"MaxAbsEn","role":"maximum-absolute-value reduction selector"},{"field":"Func","role":"fixed B.FPATR function discriminator equal to 2"},{"field":"ElementWiseEn","role":"fixed complete-bundle selector equal to zero"},{"field":"Reserved","role":"fixed-zero reserved field"},{"field":"Opc1","role":"fixed command-class discriminator equal to 2"},{"field":"Opcode","role":"fixed block-attribute opcode discriminator equal to 1"},{"field":"W","role":"fixed 32-bit command-width discriminator equal to 1"}],"ordering":["Complete field, B.DATR, operand-schema, alias, shape, and allocation preflight precedes every source consumption and destination effect.","D, RowMaxOut, and GroupMaxOut are published as one atomic complete-block output group; rejection exposes none of them."],"standalone_opcode":true,"state_effects":["Latch the accepted fixed-point post-processing descriptor once for the active block; bundle reset clears its presence and every field.","Trap save and recovery preserve the complete latched descriptor with the pending block.","Successful execution applies the selected conversion, optional activation, and optional reductions to the completed Matrix result through the numeric-profile hook, then atomically commits enabled outputs."]}}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-FPATR-MATRIX-POSTPROCESS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.FPATR MUST appear exactly once in every CUBE Matrix block and MUST precede
// every effective B.IOR, B.IOT, or B.IOS binding. Reserved mode values MUST
// reject before descriptor state or effects. Enabled D, RowMaxOut, and
// GroupMaxOut results MUST publish as one atomic output group.
// NDF-END: PTO-B-FPATR-MATRIX-POSTPROCESS-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_FPATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_fpatr_32_4f2db11e8e8a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
// PreQuantMode is deliberately a closed code table.  In particular U8 is not
// a synonym for S8 and generic FP8 resolves to E4M3 in the PTO type namespace.
pure func BundleFPATRPreQuantModeLegal(code: bits(6)) => boolean
begin
    let value = UInt(code);
    return value == 0 || value == 1 || value == 2 || value == 3 ||
           value == 4 || value == 5 || value == 12 || value == 13 ||
           value == 16 || value == 17 || value == 18 || value == 19 ||
           value == 20 || value == 23 || value == 24 || value == 25 ||
           value == 26 || value == 27 || value == 28 || value == 32 ||
           value == 33 || value == 34 || value == 35 || value == 36 ||
           value == 37 || value == 38 || value == 39;
end;

pure func BundleFPATRReluModeLegal(code: bits(3)) => boolean
begin
    return UInt(code) <= 3;
end;

pure func BundleFPATRGroupNCodeLegal(code: bits(4)) => boolean
begin
    return UInt(code) <= 9;
end;

pure func BundleFPATRGroupN(code: bits(4)) => integer {0,8,16,32,48,64,80,96,112,128}
begin
    case UInt(code) of
        when 0 => return 0;
        when 1 => return 8;
        when 2 => return 16;
        when 3 => return 32;
        when 4 => return 48;
        when 5 => return 64;
        when 6 => return 80;
        when 7 => return 96;
        when 8 => return 112;
        when 9 => return 128;
        otherwise => unreachable;
    end;
end;

pure func BundleFPATRModeUsesVectorParameter(code: bits(6)) => boolean
begin
    return UInt(code) == 2 || UInt(code) == 4 || UInt(code) == 12 ||
           UInt(code) == 18 || UInt(code) == 20 || UInt(code) == 23 ||
           UInt(code) == 28 || UInt(code) == 33 || UInt(code) == 36 ||
           UInt(code) == 37 || UInt(code) == 38 || UInt(code) == 39;
end;

pure func BundleFPATRModeUsesScalarParameter(code: bits(6)) => boolean
begin
    return UInt(code) == 3 || UInt(code) == 5 || UInt(code) == 13 ||
           UInt(code) == 17 || UInt(code) == 19 || UInt(code) == 24 ||
           UInt(code) == 25 || UInt(code) == 26 || UInt(code) == 27 ||
           UInt(code) == 32 || UInt(code) == 34 || UInt(code) == 35;
end;

pure func BundleFPATRReluModeUsesScalarParameter(code: bits(3)) => boolean
begin
    return UInt(code) == 2;
end;

pure func BundleFPATRReluModeUsesVectorParameter(code: bits(3)) => boolean
begin
    return UInt(code) == 3;
end;

// Quantization descriptors use one closed 64-bit carrier.  The selected
// mode alone determines which payload bits are meaningful; every other bit
// is reserved and must be zero before matrix operands are snapshotted.
pure func BundleFPATRQuantParameterWordLegal(code: bits(6),
                                             value: Word) => boolean
begin
    let mode = UInt(code);
    if mode == 12 || mode == 13 then
        return value[31:0] == Zeros{32} &&
               value[63:36] == Zeros{28};
    end;
    if mode == 17 || mode == 18 then
        return value[12:0] == Zeros{13} &&
               value[36:32] == Zeros{5} &&
               value[63:42] == Zeros{22};
    end;
    if mode == 2 || mode == 3 || mode == 23 || mode == 24 then
        return value[12:0] == Zeros{13} &&
               value[36:32] == Zeros{5} &&
               value[63:46] == Zeros{18};
    end;
    if mode == 19 || mode == 20 then
        return value[12:0] == Zeros{13} &&
               value[36:32] == Zeros{5} &&
               value[63:54] == Zeros{10};
    end;
    if BundleFPATRModeUsesScalarParameter(code) ||
       BundleFPATRModeUsesVectorParameter(code) then
        return value[12:0] == Zeros{13} &&
               value[63:32] == Zeros{32};
    end;
    return FALSE;
end;

// Scalar LReLU and vector PReLU elements carry one FP19 value in the low
// nineteen bits.  FP19 arithmetic remains profile-owned, but its carrier is
// architectural and therefore rejects nonzero high bits.
pure func BundleFPATRReluParameterWordLegal(value: Word) => boolean
begin
    return value[63:19] == Zeros{45};
end;

// Matrix B.DATR contributes only the destination conversion controls once
// B.FPATR is present.  None keeps the architectural default conversion
// (RMode=NONE and Sat=0); every accepted non-zero mode carries the complete
// existing rounding selector and saturation bit.  The numeric profile owns
// the resulting conversion details.
pure func BundleFPATRDATRFieldsLegal(pre_quant: bits(6),
                                     rounding_mode: bits(3),
                                     saturating: boolean) => boolean
begin
    if !BundleFPATRPreQuantModeLegal(pre_quant) then return FALSE; end;
    if UInt(pre_quant) == 0 then
        return rounding_mode == Zeros{3} && !saturating;
    end;
    // Shift pre-quant modes are fixed-point shifts.  They do not expose a
    // rounding selector; saturation remains an independent D-only control.
    if UInt(pre_quant) == 12 || UInt(pre_quant) == 13 then
        return rounding_mode == Zeros{3};
    end;
    return TRUE;
end;

pure func BundleFPATROutputType(code: bits(6)) => TileDataType
begin
    case UInt(code) of
        when 0 => return TileDataType_FP32;
        when 1, 4, 5, 32, 33 => return TileDataType_FP16;
        when 2, 3, 23, 24 => return TileDataType_S8;
        when 12, 13, 19, 20 => return TileDataType_S16;
        when 16, 34, 35, 36, 39 => return TileDataType_BF16;
        when 17, 18 => return TileDataType_S4X2;
        when 25, 28 => return TileDataType_HiF8;
        when 26, 37 => return TileDataType_E4M3;
        when 27, 38 => return TileDataType_FP32;
        otherwise => unreachable;
    end;
end;

pure func BundleFPATRFieldsLegal(pre_quant: bits(6), relu: bits(3),
                                 group_n: bits(4), row_max: boolean,
                                 group_max: boolean, row_init: boolean,
                                 max_abs: boolean) => boolean
begin
    if !BundleFPATRPreQuantModeLegal(pre_quant) ||
       !BundleFPATRReluModeLegal(relu) ||
       !BundleFPATRGroupNCodeLegal(group_n) then return FALSE; end;
    if !row_max && row_init then return FALSE; end;
    if !group_max && UInt(group_n) != 0 then return FALSE; end;
    if group_max && UInt(group_n) == 0 then return FALSE; end;
    if !row_max && !group_max && max_abs then return FALSE; end;
    return TRUE;
end;

readonly func InstructionContractHandler_B_FPATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleFixedPointAttributes;
end;

pure func InstructionContractHeaderOnly_B_FPATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_FPATR()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
