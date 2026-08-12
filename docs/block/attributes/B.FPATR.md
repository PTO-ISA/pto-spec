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
| b_fpatr_32_4f2db11e8e8a | L32 | 32 | 0x00002023 / 0x00007fff | [{"field":"PreQuantMode","operator":"one-of","values":[0,1,2,3,4,5,12,13,16,17,18,19,20,23,24,25,26,27,28,32,33,34,35,36,37,38,39]},{"field":"ReluMode","operator":"one-of","values":[0,1,2,3]},{"field":"GroupNCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9]},{"field":"RowMaxEn","operator":"one-of","values":[0,1]},{"field":"GroupMaxEn","operator":"one-of","values":[0,1]},{"field":"RowMaxInit","operator":"one-of","values":[0,1]},{"field":"MaxAbsEn","operator":"one-of","values":[0,1]},{"field":"Func","operator":"one-of","values":[2]},{"field":"ElementWiseEn","operator":"one-of","values":[0]},{"field":"Opc1","operator":"one-of","values":[2]},{"field":"Opcode","operator":"one-of","values":[1]},{"field":"W","operator":"one-of","values":[1]}] |

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| PreQuantMode | encoded operand or control |
| ReluMode | encoded operand or control |
| GroupNCode | encoded operand or control |
| RowMaxEn | encoded operand or control |
| GroupMaxEn | encoded operand or control |
| RowMaxInit | encoded operand or control |
| MaxAbsEn | encoded operand or control |
| Func | encoded operand or control |
| ElementWiseEn | encoded operand or control |
| Reserved | encoded operand or control |
| Opc1 | encoded operand or control |
| Opcode | encoded operand or control |
| W | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.FPATR.asl -->
```asl
readonly func InstructionContractMatches_B_FPATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_fpatr_32_4f2db11e8e8a);
end;
```
<!-- GENERATED-ASL-END: decode -->

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

pure func BundleFPATRReluModeUsesScalarParameter(code: bits(3)) => boolean
begin
    return UInt(code) == 2;
end;

pure func BundleFPATRReluModeUsesVectorParameter(code: bits(3)) => boolean
begin
    return UInt(code) == 3;
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
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Constraints:** `[{"field": "PreQuantMode", "operator": "one-of", "values": [0, 1, 2, 3, 4, 5, 12, 13, 16, 17, 18, 19, 20, 23, 24, 25, 26, 27, 28, 32, 33, 34, 35, 36, 37, 38, 39]}, {"field": "ReluMode", "operator": "one-of", "values": [0, 1, 2, 3]}, {"field": "GroupNCode", "operator": "one-of", "values": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]}, {"field": "RowMaxEn", "operator": "one-of", "values": [0, 1]}, {"field": "GroupMaxEn", "operator": "one-of", "values": [0, 1]}, {"field": "RowMaxInit", "operator": "one-of", "values": [0, 1]}, {"field": "MaxAbsEn", "operator": "one-of", "values": [0, 1]}, {"field": "Func", "operator": "one-of", "values": [2]}, {"field": "ElementWiseEn", "operator": "one-of", "values": [0]}, {"field": "Opc1", "operator": "one-of", "values": [2]}, {"field": "Opcode", "operator": "one-of", "values": [1]}, {"field": "W", "operator": "one-of", "values": [1]}]`

## Operational information

- **Semantic summary:** `Latches complete-bundle matrix post-processing mode, reduction enables, and fixed-point descriptor controls.`
- **Semantic handler:** `SetBundleFixedPointAttributes`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
