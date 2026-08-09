<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
# TEXTRACT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl`

Extract a rectangular source region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TEXTRACT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TEXTRACT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXTRACT | TEPL | 0x062 | 2 | 3 | TEXTRACT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| natural0 | row-offset |
| natural1 | column-offset |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractOperation_TEXTRACT() => TileOperation
begin
    return TileOperation_TEXTRACT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TEXTRACT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractHandler_TEXTRACT() => TileSemanticHandler
begin
    return TileHandler_TEXTRACT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TEXTRACT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TEXTRACT`
- **Effect contract:** `TEXTRACT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:natural0:row-offset", "operand:natural1:column-offset"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
