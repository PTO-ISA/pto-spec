<!-- GENERATED FROM: asl/tile/complex-layout/format-conversion/TQUANT.asl -->
# TQUANT

**Normative ASL source:** `asl/tile/complex-layout/format-conversion/TQUANT.asl`

Execute the TQUANT Tile operation contract.

## Normative identity {#PTO-INST-TILE-TQUANT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TQUANT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TQUANT | TEPL | 0x06A | 10 | 3 | TQUANT |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractOperation_TQUANT() => TileOperation
begin
    return TileOperation_TQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TQUANT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractHandler_TQUANT() => TileSemanticHandler
begin
    return TileHandler_TQUANT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
