<!-- GENERATED FROM: asl/tile/tile-scalar-elementwise/logical/TANDS.asl -->
# TANDS

**Normative ASL source:** `asl/tile/tile-scalar-elementwise/logical/TANDS.asl`

Execute the TANDS Tile operation contract.

## Normative identity {#PTO-INST-TILE-TANDS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TANDS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TANDS | TEPL | 0x026 | 6 | 1 | ExecuteTileScalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/logical/TANDS.asl -->
```asl
readonly func InstructionContractOperation_TANDS() => TileOperation
begin
    return TileOperation_TANDS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TANDS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/logical/TANDS.asl -->
```asl
readonly func InstructionContractHandler_TANDS() => TileSemanticHandler
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
