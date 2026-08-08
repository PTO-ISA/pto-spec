<!-- GENERATED FROM: asl/tile/reduction/column-reduction/TCOLARGMIN.asl -->
# TCOLARGMIN

**Normative ASL source:** `asl/tile/reduction/column-reduction/TCOLARGMIN.asl`

Reduce each source col to its minimum index.

## Normative identity {#PTO-INST-TILE-TCOLARGMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCOLARGMIN <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLARGMIN | TEPL | 0x05D | 29 | 2 | ExecuteTileReduction |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduction/column-reduction/TCOLARGMIN.asl -->
```asl
readonly func InstructionContractOperation_TCOLARGMIN() => TileOperation
begin
    return TileOperation_TCOLARGMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TCOLARGMIN, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduction/column-reduction/TCOLARGMIN.asl -->
```asl
readonly func InstructionContractHandler_TCOLARGMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileReduction`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileReduction`
- **Effect contract:** `ExecuteTileReduction`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
