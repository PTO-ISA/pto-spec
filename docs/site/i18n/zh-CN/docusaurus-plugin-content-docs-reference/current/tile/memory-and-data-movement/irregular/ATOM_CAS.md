<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/ATOM_CAS.asl -->
# ATOM_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/ATOM_CAS.asl`

GM indexed atomic compare-and-swap with observed-old destination.

## Normative identity {#PTO-INST-TILE-ATOM-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
ATOM_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| ATOM_CAS | TLSU |  | 8 |  | GM_ATOM_CAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| source0 | indices |
| source1 | expected |
| source2 | replacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/ATOM_CAS.asl -->
```asl
readonly func InstructionContractMatches_ATOM_CAS(operation: TileOperation) => boolean
begin
    return operation == TileOperation_ATOM_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.ATOM.CAS DataType
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/ATOM_CAS.asl -->
```asl
readonly func InstructionContractHandler_ATOM_CAS() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_CAS;
end;
readonly func InstructionContractOperation_ATOM_CAS() => TileOperation
begin
    return TileOperation_ATOM_CAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Function 8 preserves the 0x00811181 binary carrier; atom.cas is legal only for U16, U32, and U64.

## Legality

- atom.cas uses raw U16/U32/U64 carriers; U128 and all non-U types are rejected.

## State effects

- Returns observed old values in the destination.

## Memory effects and ordering

### Memory effects

- One atomic compare-and-swap per valid request.

### Ordering

- Duplicate addresses serialize in implementation-defined order.

## Exceptions

- Unsupported operation/type tuples raise Fault_TileLegality before effects.

## Examples

- BSTART.ATOM.CAS DataType; B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
