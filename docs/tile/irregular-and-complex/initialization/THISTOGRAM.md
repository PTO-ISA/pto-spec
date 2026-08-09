<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl -->
# THISTOGRAM

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl`

Accumulate a histogram from source values and selected-byte indices.

## Normative identity {#PTO-INST-TILE-THISTOGRAM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
THISTOGRAM <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| THISTOGRAM | TEPL | 0x068 | 8 | 3 | THISTOGRAM |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| source1 | indices |
| selected_byte | selected-byte |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractOperation_THISTOGRAM() => TileOperation
begin
    return TileOperation_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU THISTOGRAM, DataType
B.DATR selected_byte
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractHandler_THISTOGRAM() => TileSemanticHandler
begin
    return TileHandler_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_THISTOGRAM`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["PadValueOrByteId", "DataType"], "pad_union": "histogram-byte-id"}`

## Operational information

- **Semantic handler:** `THISTOGRAM`
- **Effect contract:** `THISTOGRAM`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:source1:indices", "operand:selected_byte:selected-byte"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
