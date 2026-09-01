<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/ATOM_OR.asl -->
# ATOM_OR

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/ATOM_OR.asl`

GM indexed atom.or operation.

## Normative identity {#PTO-INST-TILE-ATOM-OR}

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
ATOM_OR <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| ATOM_OR | TLSU |  | 17 |  | GM_ATOM_VALUE |

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
| source1 | value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/ATOM_OR.asl -->
```asl
readonly func InstructionContractMatches_ATOM_OR(operation: TileOperation) => boolean
begin
    return operation == TileOperation_ATOM_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.ATOM.OR DataType
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/ATOM_OR.asl -->
```asl
readonly func InstructionContractHandler_ATOM_OR() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_VALUE;
end;
readonly func InstructionContractOperation_ATOM_OR() => TileOperation
begin
    return TileOperation_ATOM_OR;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- GM indexed operation uses byte-displacement addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.

## State effects

- All valid requests take effect; atom forms publish observed old values.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.ATOM.OR DataType
