<!-- GENERATED FROM: asl/tile/complex-layout/initialization/TTRI.asl -->
# TTRI

**Normative ASL source:** `asl/tile/complex-layout/initialization/TTRI.asl`

Execute the TTRI Tile operation contract.

## Normative identity {#PTO-INST-TILE-TTRI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TTRI <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TTRI | TEPL | 0x067 | 7 | 3 | TTRI |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/initialization/TTRI.asl -->
```asl
readonly func InstructionContractOperation_TTRI() => TileOperation
begin
    return TileOperation_TTRI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TTRI, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/initialization/TTRI.asl -->
```asl
readonly func InstructionContractHandler_TTRI() => TileSemanticHandler
begin
    return TileHandler_TTRI;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
