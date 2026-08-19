<!-- GENERATED FROM: asl/block/attributes/B.FPATR.asl -->
# B.FPATR

**Normative ASL source:** `asl/block/attributes/B.FPATR.asl`

Latches complete-bundle matrix post-processing mode, reduction enables, and fixed-point descriptor controls.

## Normative identity {#PTO-INST-BLOCK-B-FPATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_fpatr_32_4f2db11e8e8a | L32 | 32 | 0x00002023 / 0x00007fff | [{"field":"PreQuantMode","operator":"one-of","values":[0,1,2,3,4,5,12,13,16,17,18,19,20,23,24,25,26,27,28,32,33,34,35,36,37,38,39]},{"field":"ReluMode","operator":"one-of","values":[0,1,2,3]},{"field":"GroupNCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9]},{"field":"RowMaxEn","operator":"one-of","values":[0,1]},{"field":"GroupMaxEn","operator":"one-of","values":[0,1]},{"field":"RowMaxInit","operator":"one-of","values":[0,1]},{"field":"MaxAbsEn","operator":"one-of","values":[0,1]},{"field":"Func","operator":"one-of","values":[2]},{"field":"ElementWiseEn","operator":"one-of","values":[0]},{"field":"Reserved","operator":"one-of","values":[0]},{"field":"Opc1","operator":"one-of","values":[2]},{"field":"Opcode","operator":"one-of","values":[1]},{"field":"W","operator":"one-of","values":[1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_fpatr_32_4f2db11e8e8a | PreQuantMode | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_fpatr_32_4f2db11e8e8a | ReluMode | 3 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":3}] |
| b_fpatr_32_4f2db11e8e8a | GroupNCode | 4 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":4}] |
| b_fpatr_32_4f2db11e8e8a | RowMaxEn | 1 | encoding-defined | [{"instruction_lsb":18,"value_lsb":0,"width":1}] |
| b_fpatr_32_4f2db11e8e8a | GroupMaxEn | 1 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":1}] |
| b_fpatr_32_4f2db11e8e8a | RowMaxInit | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_fpatr_32_4f2db11e8e8a | MaxAbsEn | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |
| b_fpatr_32_4f2db11e8e8a | Func | 3 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":3}] |
| b_fpatr_32_4f2db11e8e8a | ElementWiseEn | 1 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":1}] |
| b_fpatr_32_4f2db11e8e8a | Reserved | 4 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":4}] |
| b_fpatr_32_4f2db11e8e8a | Opc1 | 3 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":3}] |
| b_fpatr_32_4f2db11e8e8a | Opcode | 3 | encoding-defined | [{"instruction_lsb":1,"value_lsb":0,"width":3}] |
| b_fpatr_32_4f2db11e8e8a | W | 1 | encoding-defined | [{"instruction_lsb":0,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_fpatr_32_4f2db11e8e8a | PreQuantMode | 6 | 0–5, 12–13, 16–20, 23–28, 32–39 | none | 6–11, 14–15, 21–22, 29–31, 40–63 | closed Matrix destination pre-quantization and output-type selector | No pre-quantization; D retains the FP32, S32, or U32 accumulator type. |
| b_fpatr_32_4f2db11e8e8a | ReluMode | 3 | 0–3 | none | 4–7 | pre-conversion activation multiplier selector | No activation. |
| b_fpatr_32_4f2db11e8e8a | GroupNCode | 4 | 0–9 | none | 10–15 | group maximum column-count selector | No group maximum; GroupMaxEn must also be zero. |
| b_fpatr_32_4f2db11e8e8a | RowMaxEn | 1 | 0–1 | none | none | row maximum input/output enable | No RowMax input or output. |
| b_fpatr_32_4f2db11e8e8a | GroupMaxEn | 1 | 0–1 | none | none | group maximum output enable | No GroupMax output. |
| b_fpatr_32_4f2db11e8e8a | RowMaxInit | 1 | 0–1 | none | none | row maximum initialization from RowMaxIn enable | Do not initialize RowMax from RowMaxIn. |
| b_fpatr_32_4f2db11e8e8a | MaxAbsEn | 1 | 0–1 | none | none | maximum-absolute-value reduction selector | Use signed maximum rather than maximum absolute value for enabled reductions. |
| b_fpatr_32_4f2db11e8e8a | Func | 3 | 2 | none | 0–1, 3–7 | fixed B.FPATR function discriminator equal to 2 | Encoded zero supplies numeric zero for the fixed B.FPATR function discriminator equal to 2. |
| b_fpatr_32_4f2db11e8e8a | ElementWiseEn | 1 | 0 | none | 1 | fixed complete-bundle selector equal to zero | Fixed zero selects complete-bundle Matrix post-processing. |
| b_fpatr_32_4f2db11e8e8a | Reserved | 4 | 0 | none | 1–15 | fixed-zero reserved field | Fixed zero; every nonzero encoding is reserved. |
| b_fpatr_32_4f2db11e8e8a | Opc1 | 3 | 2 | none | 0–1, 3–7 | fixed command-class discriminator equal to 2 | Encoded zero supplies numeric zero for the fixed command-class discriminator equal to 2. |
| b_fpatr_32_4f2db11e8e8a | Opcode | 3 | 1 | none | 0, 2–7 | fixed block-attribute opcode discriminator equal to 1 | Encoded zero supplies numeric zero for the fixed block-attribute opcode discriminator equal to 1. |
| b_fpatr_32_4f2db11e8e8a | W | 1 | 1 | none | 0 | fixed 32-bit command-width discriminator equal to 1 | Encoded zero supplies numeric zero for the fixed 32-bit command-width discriminator equal to 1. |

- `b_fpatr_32_4f2db11e8e8a.PreQuantMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.ReluMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.GroupNCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.Func` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.ElementWiseEn` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.Reserved` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.Opc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.Opcode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_4f2db11e8e8a.W` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| PreQuantMode | closed Matrix destination pre-quantization and output-type selector |
| ReluMode | pre-conversion activation multiplier selector |
| GroupNCode | group maximum column-count selector |
| RowMaxEn | row maximum input/output enable |
| GroupMaxEn | group maximum output enable |
| RowMaxInit | row maximum initialization from RowMaxIn enable |
| MaxAbsEn | maximum-absolute-value reduction selector |
| Func | fixed B.FPATR function discriminator equal to 2 |
| ElementWiseEn | fixed complete-bundle selector equal to zero |
| Reserved | fixed-zero reserved field |
| Opc1 | fixed command-class discriminator equal to 2 |
| Opcode | fixed block-attribute opcode discriminator equal to 1 |
| W | fixed 32-bit command-width discriminator equal to 1 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.FPATR.asl -->
```asl
readonly func InstructionContractMatches_B_FPATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_fpatr_32_4f2db11e8e8a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Required exactly once in a CUBE Matrix block after BSTART and before scalar or tile bindings and the first body instruction.
The complete block schema places mathematical Local sources first, then optional RowMaxIn, vector pre-quantization, and vector PReLU sources; Local destinations are D, optional RowMaxOut, then optional GroupMaxOut.
Scalar pre-quantization and LReLU/PReLU parameters use the dense B.IOR schema; LReLU-only consumes RegSrc0.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.FPATR.asl -->
```asl
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

pure func BundleFPATRModeUsesS32Accumulator(code: bits(6)) => boolean
begin
    let value = UInt(code);
    return value == 2 || value == 3 || value == 4 || value == 5 ||
           value == 12 || value == 13 || value == 17 || value == 18 ||
           value == 19 || value == 20 || value == 35 || value == 39;
end;

pure func BundleFPATRModeUsesFP32Accumulator(code: bits(6)) => boolean
begin
    return BundleFPATRPreQuantModeLegal(code) &&
           UInt(code) != 0 &&
           !BundleFPATRModeUsesS32Accumulator(code);
end;

pure func BundleFPATRAccumulatorTypeLegal(
    code: bits(6), accumulator_type: TileDataType) => boolean
begin
    if UInt(code) == 0 then
        return accumulator_type == TileDataType_FP32 ||
               accumulator_type == TileDataType_S32 ||
               accumulator_type == TileDataType_U32;
    elsif BundleFPATRModeUsesS32Accumulator(code) then
        return accumulator_type == TileDataType_S32;
    elsif BundleFPATRModeUsesFP32Accumulator(code) then
        return accumulator_type == TileDataType_FP32;
    end;
    return FALSE;
end;

pure func BundleFPATRModeOffsetWidth(code: bits(6))
    => integer {0,5,9,17}
begin
    let value = UInt(code);
    if value == 17 || value == 18 then return 5;
    elsif value == 2 || value == 3 || value == 23 || value == 24 then
        return 9;
    elsif value == 19 || value == 20 then return 17;
    else return 0;
    end;
end;

pure func BundleFPATRModeIsShift(code: bits(6)) => boolean
begin
    return UInt(code) == 12 || UInt(code) == 13;
end;

pure func BundleFPATRModeFixedRounding(code: bits(6)) => boolean
begin
    let value = UInt(code);
    return value == 1 || value == 16 || value == 25 || value == 26 ||
           value == 28 || value == 32 || value == 33 || value == 34 ||
           value == 36 || value == 37;
end;

pure func BundleFPATRModeFinalSatProgrammable(code: bits(6)) => boolean
begin
    return UInt(code) != 0 && !BundleFPATRModeIsShift(code);
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
               FP19ScaleLegal(value[31:13]) &&
               value[36:32] == Zeros{5} &&
               value[63:42] == Zeros{22};
    end;
    if mode == 2 || mode == 3 || mode == 23 || mode == 24 then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[36:32] == Zeros{5} &&
               value[63:46] == Zeros{18};
    end;
    if mode == 19 || mode == 20 then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[36:32] == Zeros{5} &&
               value[63:54] == Zeros{10};
    end;
    if BundleFPATRModeUsesScalarParameter(code) ||
       BundleFPATRModeUsesVectorParameter(code) then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[63:32] == Zeros{32};
    end;
    return FALSE;
end;

// Scalar LReLU and vector PReLU elements carry one FP19 value in the low
// nineteen bits.  FP19 arithmetic remains profile-owned, but its carrier is
// architectural and therefore rejects nonzero high bits.
pure func BundleFPATRReluParameterWordLegal(value: Word) => boolean
begin
    return value[63:19] == Zeros{45} &&
           FP19ActivationParameterLegal(value[18:0]);
end;

// Matrix B.DATR contributes only the destination conversion controls once
// B.FPATR is present.  None keeps the architectural default conversion
// (RMode=NONE and Sat=0). Fixed floating modes reject a non-default RMode;
// fixed shift modes additionally reject Sat. Other accepted modes retain the
// complete rounding selector and final saturation control.
pure func BundleFPATRDATRFieldsLegal(pre_quant: bits(6),
                                     rounding_mode: bits(3),
                                     saturating: boolean) => boolean
begin
    if !BundleFPATRPreQuantModeLegal(pre_quant) then return FALSE; end;
    if UInt(pre_quant) == 0 then
        return rounding_mode == Zeros{3} && !saturating;
    end;
    if BundleFPATRModeIsShift(pre_quant) then
        return rounding_mode == Zeros{3} && !saturating;
    end;
    if BundleFPATRModeFixedRounding(pre_quant) then
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
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded PreQuantMode=0 and ReluMode=0 disable pre-quantization and activation. GroupNCode=0 selects no group maximum. All four enable bits default to disabled.
- Omitting B.FPATR is not a default for a CUBE Matrix block: complete-bundle preflight rejects the missing command before allocation or effects.

## Legality

- PreQuantMode accepts exactly codes 0..5, 12..13, 16..20, 23..28, and 32..39; all other six-bit codes are reserved.
- Each nonzero PreQuantMode accepts exactly its assigned S32 or FP32 accumulator class; code zero accepts FP32, S32, or U32 and preserves that type.
- ReluMode codes 0..3 select None, ReLU, scalar LReLU/PReLU, and vector PReLU; codes 4..7 are reserved.
- GroupNCode codes 0..9 select 0, 8, 16, 32, 48, 64, 80, 96, 112, and 128 columns; codes 10..15 are reserved.
- RowMaxInit requires RowMaxEn. GroupMaxEn requires nonzero GroupNCode and nonzero GroupNCode requires GroupMaxEn. MaxAbsEn requires RowMaxEn or GroupMaxEn.
- Func=2, ElementWiseEn=0, Reserved=0, Opc1=2, Opcode=1, and W=1 are fixed encoding discriminators.
- Matrix B.DATR supplies only destination conversion controls when B.FPATR is present: None requires RMode=NONE and Sat=0; fixed floating modes require RMode=NONE; fixed shift modes require RMode=NONE and Sat=0; programmable integer modes retain the complete rounding selector and final clamp/wrap control.
- The derived scalar/vector parameter count, Local source count, and Local destination count must fit the complete-bundle schema without duplicate destinations or illegal source/destination aliases.

## State effects

- Latch the accepted fixed-point post-processing descriptor once for the active block; bundle reset clears its presence and every field.
- Trap save and recovery preserve the complete latched descriptor with the pending block.
- Successful execution selects any activation-dependent multiplier before the destination conversion, preserves raw optional reductions, and atomically commits all enabled outputs through the numeric-profile hook.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete field, B.DATR, operand-schema, alias, shape, and allocation preflight precedes every source consumption and destination effect.
- D, RowMaxOut, and GroupMaxOut are published as one atomic complete-block output group; rejection exposes none of them.

## Exceptions

- Missing, duplicate, or non-CUBE-Matrix use raises Fault_BundleControl before operand consumption, allocation, payload, or destination effects.
- Decode-reserved field values do not decode and raise Fault_IllegalInstruction. Accepted encodings with inconsistent reduction enables, invalid B.DATR conversion controls, invalid parameters, malformed operand streams, illegal aliases, or invalid derived shapes raise Fault_TileLegality before effects.
- Fixed-bit mismatch does not decode as B.FPATR and is rejected by normal command decoding before this handler executes.

## Examples

- B.FPATR None, None, 0, 0, 0, 0, 0
- B.FPATR S8Vector, LReLU, 2, 1, 1, 1, 1

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
