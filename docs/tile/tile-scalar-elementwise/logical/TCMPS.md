<!-- GENERATED FROM: asl/tile/tile-scalar-elementwise/logical/TCMPS.asl -->
# TCMPS

**Normative ASL source:** `asl/tile/tile-scalar-elementwise/logical/TCMPS.asl`

Execute the TCMPS Tile operation contract.

## Normative identity {#PTO-INST-TILE-TCMPS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCMPS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMPS | TEPL | 0x02D | 13 | 1 | ExecuteTileCompareScalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/logical/TCMPS.asl -->
```asl
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TCMPS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/logical/TCMPS.asl -->
```asl
readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
