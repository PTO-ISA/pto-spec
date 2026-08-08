<!-- GENERATED FROM: asl/tile/tile-scalar-elementwise/arithmetic/TMAXS.asl -->
# TMAXS

**Normative ASL source:** `asl/tile/tile-scalar-elementwise/arithmetic/TMAXS.asl`

Execute the TMAXS Tile operation contract.

## Normative identity {#PTO-INST-TILE-TMAXS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TMAXS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMAXS | TEPL | 0x02B | 11 | 1 | ExecuteTileScalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/arithmetic/TMAXS.asl -->
```asl
readonly func InstructionContractOperation_TMAXS() => TileOperation
begin
    return TileOperation_TMAXS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TMAXS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/arithmetic/TMAXS.asl -->
```asl
readonly func InstructionContractHandler_TMAXS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
