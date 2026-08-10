<!-- GENERATED FROM: asl/tile/irregular-and-complex/sorting/TMRGSORT.asl -->
# TMRGSORT

**Normative ASL source:** `asl/tile/irregular-and-complex/sorting/TMRGSORT.asl`

Merge two sorted source Tiles in the selected ascending or descending order.

## Normative identity {#PTO-INST-TILE-TMRGSORT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TMRGSORT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMRGSORT | TEPL | 0x06D | 13 | 3 | TMRGSORT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |
| flag0 | descending |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/sorting/TMRGSORT.asl -->
```asl
readonly func InstructionContractOperation_TMRGSORT() => TileOperation
begin
    return TileOperation_TMRGSORT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TMRGSORT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/sorting/TMRGSORT.asl -->
```asl
// Complete-bundle B.IOR consumes descending in RegSrc0. Omission keeps the
// ascending default; encoded zero is explicit. Equal keys select the left
// source first, and inputs must already be sorted in the selected direction.
readonly func InstructionContractHandler_TMRGSORT() => TileSemanticHandler
begin
    return TileHandler_TMRGSORT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TMRGSORT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TMRGSORT`
- **Effect contract:** `TMRGSORT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source-left", "operand:source1:source-right", "operand:flag0:descending"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
