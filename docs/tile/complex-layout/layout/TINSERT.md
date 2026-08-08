<!-- GENERATED FROM: asl/tile/complex-layout/layout/TINSERT.asl -->
# TINSERT

**Normative ASL source:** `asl/tile/complex-layout/layout/TINSERT.asl`

Execute the TINSERT Tile operation contract.

## Normative identity {#PTO-INST-TILE-TINSERT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TINSERT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TINSERT | TEPL | 0x063 | 3 | 3 | TINSERT |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TINSERT.asl -->
```asl
readonly func InstructionContractOperation_TINSERT() => TileOperation
begin
    return TileOperation_TINSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TINSERT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TINSERT.asl -->
```asl
readonly func InstructionContractHandler_TINSERT() => TileSemanticHandler
begin
    return TileHandler_TINSERT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
