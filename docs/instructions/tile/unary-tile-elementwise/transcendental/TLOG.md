# TLOG

Execute the TLOG Tile operation contract.

<!-- ASL-SOURCE: asl/tile/unary-tile-elementwise/transcendental/TLOG.asl -->

## Normative identity {#PTO-INST-TILE-TLOG}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TLOG <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLOG | TEPL | 0x013 | 19 | 0 | ExecuteTileUnary |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/unary-tile-elementwise/transcendental/TLOG.asl -->
```asl
readonly func InstructionContractOperation_TLOG() => TileOperation
begin
    return TileOperation_TLOG;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TLOG, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/unary-tile-elementwise/transcendental/TLOG.asl -->
```asl
readonly func InstructionContractHandler_TLOG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
