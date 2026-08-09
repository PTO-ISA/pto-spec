<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl -->
# TIMG2COL

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl`

Transform an image Tile into kernel-column layout using kernel, stride, padding, and fill operands.

## Normative identity {#PTO-INST-TILE-TIMG2COL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TIMG2COL <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TIMG2COL | TEPL | 0x064 | 4 | 3 | TIMG2COL |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| positive0 | kernel-rows |
| positive1 | kernel-columns |
| positive2 | stride-rows |
| positive3 | stride-columns |
| natural0 | pad-rows |
| natural1 | pad-columns |
| scalar0 | padding |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl -->
```asl
readonly func InstructionContractOperation_TIMG2COL() => TileOperation
begin
    return TileOperation_TIMG2COL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TIMG2COL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl -->
```asl
readonly func InstructionContractHandler_TIMG2COL() => TileSemanticHandler
begin
    return TileHandler_TIMG2COL;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TIMG2COL`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TIMG2COL`
- **Effect contract:** `TIMG2COL`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:positive0:kernel-rows", "operand:positive1:kernel-columns", "operand:positive2:stride-rows", "operand:positive3:stride-columns", "operand:natural0:pad-rows", "operand:natural1:pad-columns", "operand:scalar0:padding"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
