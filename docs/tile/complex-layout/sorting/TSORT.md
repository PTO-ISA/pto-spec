<!-- GENERATED FROM: asl/tile/complex-layout/sorting/TSORT.asl -->
# TSORT

**Normative ASL source:** `asl/tile/complex-layout/sorting/TSORT.asl`

Execute the TSORT Tile operation contract.

## Normative identity {#PTO-INST-TILE-TSORT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TSORT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSORT | TEPL | 0x06C | 12 | 3 | TSORT |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/sorting/TSORT.asl -->
```asl
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSORT, DataType
B.DIM sort_width -> LB0
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/sorting/TSORT.asl -->
```asl
readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
