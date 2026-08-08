<!-- GENERATED FROM: asl/tile/matrix/matrix-vector/TGEMV.asl -->
# TGEMV

**Normative ASL source:** `asl/tile/matrix/matrix-vector/TGEMV.asl`

Execute the TGEMV Tile operation contract.

## Normative identity {#PTO-INST-TILE-TGEMV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TGEMV <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV | CUBE |  | 16 |  | TGEMV |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-vector/TGEMV.asl -->
```asl
readonly func InstructionContractOperation_TGEMV() => TileOperation
begin
    return TileOperation_TGEMV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TGEMV AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 N
B.DIM LB1 M
B.DIM LB2 Col
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-vector/TGEMV.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TGEMV_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV() => TileSemanticHandler
begin
    return TileHandler_TGEMV;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
