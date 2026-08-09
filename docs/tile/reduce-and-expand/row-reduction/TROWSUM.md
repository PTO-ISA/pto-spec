<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl -->
# TROWSUM

**Normative ASL source:** `asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl`

Reduce each source row to its sum.

## Normative identity {#PTO-INST-TILE-TROWSUM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWSUM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWSUM | TEPL | 0x040 | 0 | 2 | ExecuteTileReduction |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl -->
```asl
readonly func InstructionContractOperation_TROWSUM() => TileOperation
begin
    return TileOperation_TROWSUM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWSUM, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl -->
```asl
readonly func InstructionContractHandler_TROWSUM() => TileSemanticHandler
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
