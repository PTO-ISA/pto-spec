<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-reduction/TCOLARGMAX.asl -->
# TCOLARGMAX

**Normative ASL source:** `asl/tile/reduce-and-expand/column-reduction/TCOLARGMAX.asl`

Reduce each source col to its maximum index.

## Normative identity {#PTO-INST-TILE-TCOLARGMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLARGMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLARGMAX | TEPL | 0x05C | 28 | 2 | ExecuteTileReduction |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-reduction/TCOLARGMAX.asl -->
```asl
readonly func InstructionContractOperation_TCOLARGMAX() => TileOperation
begin
    return TileOperation_TCOLARGMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLARGMAX, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-reduction/TCOLARGMAX.asl -->
```asl
readonly func InstructionContractHandler_TCOLARGMAX() => TileSemanticHandler
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
