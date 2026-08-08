<!-- GENERATED FROM: asl/tile/memory/pe-movement/GMOV.asl -->
# GMOV

**Normative ASL source:** `asl/tile/memory/pe-movement/GMOV.asl`

Execute the GMOV Tile operation contract.

## Normative identity {#PTO-INST-TILE-GMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
GMOV <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| GMOV | TLSU |  | 13 |  | GMOV |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/pe-movement/GMOV.asl -->
```asl
readonly func InstructionContractOperation_GMOV() => TileOperation
begin
    return TileOperation_GMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TLSU GMOV, DataType
B.IOT source, destination, PE_MASK, TSize
B.IOR peer_tid
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/pe-movement/GMOV.asl -->
```asl
readonly func InstructionContractHandler_GMOV() => TileSemanticHandler
begin
    return TileHandler_GMOV;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
