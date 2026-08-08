<!-- GENERATED FROM: asl/tile/tile-tile-elementwise/logical/TSHR.asl -->
# TSHR

**Normative ASL source:** `asl/tile/tile-tile-elementwise/logical/TSHR.asl`

Execute the TSHR Tile operation contract.

## Normative identity {#PTO-INST-TILE-TSHR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TSHR <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSHR | TEPL | 0x00A | 10 | 0 | ExecuteTileBinary |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-tile-elementwise/logical/TSHR.asl -->
```asl
readonly func InstructionContractOperation_TSHR() => TileOperation
begin
    return TileOperation_TSHR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSHR, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-tile-elementwise/logical/TSHR.asl -->
```asl
readonly func InstructionContractHandler_TSHR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
