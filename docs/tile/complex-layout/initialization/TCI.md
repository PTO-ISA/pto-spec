<!-- GENERATED FROM: asl/tile/complex-layout/initialization/TCI.asl -->
# TCI

**Normative ASL source:** `asl/tile/complex-layout/initialization/TCI.asl`

Initialize destination elements as an ascending or descending counter sequence.

## Normative identity {#PTO-INST-TILE-TCI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCI <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCI | TEPL | 0x066 | 6 | 3 | TCI |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| scalar0 | start |
| flag0 | descending |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/initialization/TCI.asl -->
```asl
readonly func InstructionContractOperation_TCI() => TileOperation
begin
    return TileOperation_TCI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TCI, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/initialization/TCI.asl -->
```asl
readonly func InstructionContractHandler_TCI() => TileSemanticHandler
begin
    return TileHandler_TCI;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TCI`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TCI`
- **Effect contract:** `TCI`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:scalar0:start", "operand:flag0:descending"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
