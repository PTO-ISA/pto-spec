<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
# TCONCAT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TCONCAT.asl`

Concatenate two source Tiles along the selected axis.

## Normative identity {#PTO-INST-TILE-TCONCAT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TCONCAT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCONCAT | TEPL | 0x060 | 0 | 3 | TCONCAT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |
| axis | axis |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
```asl
readonly func InstructionContractOperation_TCONCAT() => TileOperation
begin
    return TileOperation_TCONCAT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCONCAT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
```asl
readonly func InstructionContractHandler_TCONCAT() => TileSemanticHandler
begin
    return TileHandler_TCONCAT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TCONCAT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TCONCAT`
- **Effect contract:** `TCONCAT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source-left", "operand:source1:source-right", "operand:axis:axis"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
