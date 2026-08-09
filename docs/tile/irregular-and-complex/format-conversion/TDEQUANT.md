<!-- GENERATED FROM: asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl -->
# TDEQUANT

**Normative ASL source:** `asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl`

Dequantize source elements using scale, zero point, rounding, and saturation controls.

## Normative identity {#PTO-INST-TILE-TDEQUANT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TDEQUANT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDEQUANT | TEPL | 0x06B | 11 | 3 | TDEQUANT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | scale |
| scalar1 | zero-point |
| numeric_control | rounding-and-saturation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl -->
```asl
readonly func InstructionContractOperation_TDEQUANT() => TileOperation
begin
    return TileOperation_TDEQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TDEQUANT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl -->
```asl
readonly func InstructionContractHandler_TDEQUANT() => TileSemanticHandler
begin
    return TileHandler_TDEQUANT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TDEQUANT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Sat", "Canonicalize", "DataType", "RMode", "Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TDEQUANT`
- **Effect contract:** `TDEQUANT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:scalar0:scale", "operand:scalar1:zero-point", "operand:numeric_control:rounding-and-saturation"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
