<!-- GENERATED FROM: asl/tile/tile-scalar-elementwise/arithmetic/TREMS.asl -->
# TREMS

**Normative ASL source:** `asl/tile/tile-scalar-elementwise/arithmetic/TREMS.asl`

Execute the TREMS Tile operation contract.

## Normative identity {#PTO-INST-TILE-TREMS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TREMS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TREMS | TEPL | 0x024 | 4 | 1 | ExecuteTileScalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/arithmetic/TREMS.asl -->
```asl
readonly func InstructionContractOperation_TREMS() => TileOperation
begin
    return TileOperation_TREMS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TREMS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/arithmetic/TREMS.asl -->
```asl
readonly func InstructionContractHandler_TREMS() => TileSemanticHandler
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
