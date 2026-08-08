<!-- GENERATED FROM: asl/tile/memory/regular/TSTORE.asl -->
# TSTORE

**Normative ASL source:** `asl/tile/memory/regular/TSTORE.asl`

Execute the TSTORE Tile operation contract.

## Normative identity {#PTO-INST-TILE-TSTORE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TSTORE <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSTORE | TLSU |  | 1 |  | TSTORE |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/regular/TSTORE.asl -->
```asl
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
# Local form
BSTART.TLSU TSTORE
B.DATR/B.DIM
B.IOT
B.IOR
BSTOP
# Shared full form
BSTART.TLSU Function 1
B.IOS
B.IOR
BSTOP
# Shared pe_scope form
BSTART.TLSU Function 14
B.IOS
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/regular/TSTORE.asl -->
```asl
readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
