<!-- GENERATED FROM: asl/tile/complex-layout/layout/TGATHER.asl -->
# TGATHER

**Normative ASL source:** `asl/tile/complex-layout/layout/TGATHER.asl`

Execute the TGATHER Tile operation contract.

## Normative identity {#PTO-INST-TILE-TGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TGATHER <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGATHER | TEPL | 0x06F | 15 | 3 | TGATHER |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TGATHER, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TGATHER.asl -->
```asl
readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
