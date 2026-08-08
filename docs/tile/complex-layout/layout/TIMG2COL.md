<!-- GENERATED FROM: asl/tile/complex-layout/layout/TIMG2COL.asl -->
# TIMG2COL

**Normative ASL source:** `asl/tile/complex-layout/layout/TIMG2COL.asl`

Execute the TIMG2COL Tile operation contract.

## Normative identity {#PTO-INST-TILE-TIMG2COL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TIMG2COL <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TIMG2COL | TEPL | 0x064 | 4 | 3 | TIMG2COL |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TIMG2COL.asl -->
```asl
readonly func InstructionContractOperation_TIMG2COL() => TileOperation
begin
    return TileOperation_TIMG2COL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TIMG2COL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TIMG2COL.asl -->
```asl
readonly func InstructionContractHandler_TIMG2COL() => TileSemanticHandler
begin
    return TileHandler_TIMG2COL;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
