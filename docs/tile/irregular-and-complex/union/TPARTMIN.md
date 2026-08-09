<!-- GENERATED FROM: asl/tile/irregular-and-complex/union/TPARTMIN.asl -->
# TPARTMIN

**Normative ASL source:** `asl/tile/irregular-and-complex/union/TPARTMIN.asl`

Combine corresponding source partitions by minimum selection.

## Normative identity {#PTO-INST-TILE-TPARTMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TPARTMIN <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPARTMIN | TEPL | 0x074 | 20 | 3 | ExecuteTilePartial |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/union/TPARTMIN.asl -->
```asl
readonly func InstructionContractOperation_TPARTMIN() => TileOperation
begin
    return TileOperation_TPARTMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPARTMIN, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/union/TPARTMIN.asl -->
```asl
readonly func InstructionContractHandler_TPARTMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTilePartial`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTilePartial`
- **Effect contract:** `ExecuteTilePartial`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source-left", "operand:source1:source-right"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
