<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TTRANS.asl -->
# TTRANS

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TTRANS.asl`

Transpose the source Tile into the destination.

## Normative identity {#PTO-INST-TILE-TTRANS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TTRANS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TTRANS | TEPL | 0x06E | 14 | 3 | TTRANS |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TTRANS.asl -->
```asl
readonly func InstructionContractOperation_TTRANS() => TileOperation
begin
    return TileOperation_TTRANS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TTRANS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TTRANS.asl -->
```asl
readonly func InstructionContractHandler_TTRANS() => TileSemanticHandler
begin
    return TileHandler_TTRANS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TTRANS`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TTRANS`
- **Effect contract:** `TTRANS`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
