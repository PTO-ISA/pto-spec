# THISTOGRAM

Execute the THISTOGRAM Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/initialization/THISTOGRAM.asl -->

## Normative identity {#PTO-INST-TILE-THISTOGRAM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
THISTOGRAM <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| THISTOGRAM | TEPL | 0x068 | 8 | 3 | THISTOGRAM |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractOperation_THISTOGRAM() => TileOperation
begin
    return TileOperation_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL THISTOGRAM, DataType
B.DATR selected_byte
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractHandler_THISTOGRAM() => TileSemanticHandler
begin
    return TileHandler_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
