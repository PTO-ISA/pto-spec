<!-- GENERATED FROM: asl/tile/complex-layout/format-conversion/TCVT.asl -->
# TCVT

**Normative ASL source:** `asl/tile/complex-layout/format-conversion/TCVT.asl`

Convert source elements to the destination data type under rounding and saturation controls.

## Normative identity {#PTO-INST-TILE-TCVT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCVT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCVT | TEPL | 0x01B | 27 | 0 | TCVT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| numeric_control | rounding-and-saturation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/format-conversion/TCVT.asl -->
```asl
readonly func InstructionContractOperation_TCVT() => TileOperation
begin
    return TileOperation_TCVT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TCVT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/format-conversion/TCVT.asl -->
```asl
readonly func InstructionContractHandler_TCVT() => TileSemanticHandler
begin
    return TileHandler_TCVT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TCVT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Sat", "Canonicalize", "DataType", "RMode", "Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TCVT`
- **Effect contract:** `TCVT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:numeric_control:rounding-and-saturation"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
