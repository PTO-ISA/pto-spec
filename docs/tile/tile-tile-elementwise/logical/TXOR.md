<!-- GENERATED FROM: asl/tile/tile-tile-elementwise/logical/TXOR.asl -->
# TXOR

**Normative ASL source:** `asl/tile/tile-tile-elementwise/logical/TXOR.asl`

Execute the TXOR Tile operation contract.

## Normative identity {#PTO-INST-TILE-TXOR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TXOR <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TXOR | TEPL | 0x008 | 8 | 0 | ExecuteTileBinary |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-tile-elementwise/logical/TXOR.asl -->
```asl
readonly func InstructionContractOperation_TXOR() => TileOperation
begin
    return TileOperation_TXOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TXOR, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-tile-elementwise/logical/TXOR.asl -->
```asl
readonly func InstructionContractHandler_TXOR() => TileSemanticHandler
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
