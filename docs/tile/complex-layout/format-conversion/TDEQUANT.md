<!-- GENERATED FROM: asl/tile/complex-layout/format-conversion/TDEQUANT.asl -->
# TDEQUANT

**Normative ASL source:** `asl/tile/complex-layout/format-conversion/TDEQUANT.asl`

Execute the TDEQUANT Tile operation contract.

## Normative identity {#PTO-INST-TILE-TDEQUANT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TDEQUANT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDEQUANT | TEPL | 0x06B | 11 | 3 | TDEQUANT |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/format-conversion/TDEQUANT.asl -->
```asl
readonly func InstructionContractOperation_TDEQUANT() => TileOperation
begin
    return TileOperation_TDEQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TDEQUANT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/format-conversion/TDEQUANT.asl -->
```asl
readonly func InstructionContractHandler_TDEQUANT() => TileSemanticHandler
begin
    return TileHandler_TDEQUANT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
