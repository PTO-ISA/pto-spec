<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
# TFILLPAD

**Normative ASL source:** `asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl`

Copy the source and fill destination padding elements with the bound scalar.

## Normative identity {#PTO-INST-TILE-TFILLPAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TFILLPAD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFILLPAD | TEPL | 0x065 | 5 | 3 | TFILLPAD |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | padding |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractOperation_TFILLPAD() => TileOperation
begin
    return TileOperation_TFILLPAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TFILLPAD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractHandler_TFILLPAD() => TileSemanticHandler
begin
    return TileHandler_TFILLPAD;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TFILLPAD`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["PadValueOrByteId", "Layout"], "pad_union": "pad-value"}`

## Operational information

- **Semantic handler:** `TFILLPAD`
- **Effect contract:** `TFILLPAD`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:scalar0:padding"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
