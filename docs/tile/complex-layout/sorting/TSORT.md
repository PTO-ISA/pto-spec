<!-- GENERATED FROM: asl/tile/complex-layout/sorting/TSORT.asl -->
# TSORT

**Normative ASL source:** `asl/tile/complex-layout/sorting/TSORT.asl`

Sort source groups, returning ordered values and original U32 indices.

## Normative identity {#PTO-INST-TILE-TSORT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TSORT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSORT | TEPL | 0x06C | 12 | 3 | TSORT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| destination1 | original-indices-u32 |
| source0 | source |
| sort_width | sort-width |
| flag0 | descending |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/sorting/TSORT.asl -->
```asl
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TSORT, DataType
B.DIM sort_width -> LB0
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/sorting/TSORT.asl -->
```asl
readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TSORT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TSORT`
- **Effect contract:** `TSORT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:destination1:original-indices-u32", "operand:source0:source", "operand:sort_width:sort-width", "operand:flag0:descending"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
