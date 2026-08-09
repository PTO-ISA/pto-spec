<!-- GENERATED FROM: asl/tile/irregular-and-complex/format-conversion/TQUANT.asl -->
# TQUANT

**Normative ASL source:** `asl/tile/irregular-and-complex/format-conversion/TQUANT.asl`

Quantize source elements using scale, zero point, rounding, and saturation controls.

## Normative identity {#PTO-INST-TILE-TQUANT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TQUANT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TQUANT | TEPL | 0x06A | 10 | 3 | TQUANT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | scale |
| scalar1 | zero-point |
| numeric_control | rounding-and-saturation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractOperation_TQUANT() => TileOperation
begin
    return TileOperation_TQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TQUANT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractHandler_TQUANT() => TileSemanticHandler
begin
    return TileHandler_TQUANT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TQUANT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Sat", "Canonicalize", "DataType", "RMode", "Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TQUANT`
- **Effect contract:** `TQUANT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:scalar0:scale", "operand:scalar1:zero-point", "operand:numeric_control:rounding-and-saturation"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
