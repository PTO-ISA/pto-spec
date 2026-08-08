<!-- GENERATED FROM: asl/tile/complex-layout/layout/TEXTRACT.asl -->
# TEXTRACT

**Normative ASL source:** `asl/tile/complex-layout/layout/TEXTRACT.asl`

Execute the TEXTRACT Tile operation contract.

## Normative identity {#PTO-INST-TILE-TEXTRACT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TEXTRACT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXTRACT | TEPL | 0x062 | 2 | 3 | TEXTRACT |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractOperation_TEXTRACT() => TileOperation
begin
    return TileOperation_TEXTRACT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TEXTRACT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractHandler_TEXTRACT() => TileSemanticHandler
begin
    return TileHandler_TEXTRACT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
