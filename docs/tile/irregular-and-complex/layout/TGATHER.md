<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TGATHER.asl -->
# TGATHER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TGATHER.asl`

Gather source elements by Tile indices into the destination.

## Normative identity {#PTO-INST-TILE-TGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TGATHER <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGATHER | TEPL | 0x06F | 15 | 3 | TGATHER |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| source1 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGATHER, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TGATHER`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TGATHER`
- **Effect contract:** `TGATHER`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:source1:indices"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
