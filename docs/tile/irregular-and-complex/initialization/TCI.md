<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/TCI.asl -->
# TCI

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/TCI.asl`

Generate one ascending or descending typed integer sequence in a new single-row Local Tile.

## Normative identity {#PTO-INST-TILE-TCI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TCI <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCI | TEPL | 0x066 | 6 | 3 | TCI |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local S32, S16, U32, or U16 destination |
| scalar0 | typed sequence start |
| flag0 | ascending or descending direction |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/initialization/TCI.asl -->
```asl
readonly func InstructionContractOperation_TCI() => TileOperation
begin
    return TileOperation_TCI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCI, S32|S16|U32|U16
B.DATR all-zero (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1; when present must equal 1)
B.DIM LB2=Col (optional, default ValidCol)
B.IOR Start, Direction (optional; omission selects 0 and ascending)
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/initialization/TCI.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCI(
    data_type: TileDataType) => boolean
begin
    return TileTCIDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultStart_TCI() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractDefaultDescending_TCI() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TCI(
        destination,
        start,
        descending);
end;

readonly func InstructionContractHandler_TCI() => TileSemanticHandler
begin
    return TileHandler_TCI;
end;

func InstructionContractExecute_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TCI(
        destination,
        start,
        descending);
    TCI(
        destination,
        start,
        descending);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.
- Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is always Null.

## Legality

- TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.
- The selected DataType is exactly S32, S16, U32, or U16. The destination is row-major, ValidRow is one, ValidCol is nonzero, and Col is at least ValidCol.
- A present B.IOR consumes RegSrc0 as the raw start value and RegSrc1 as an exact zero or one direction. Bits above the selected start width are ignored. RegSrc2 and RegDst are zero.
- Every explicit nonzero B.DATR field is illegal. PE_MASK zero is a strict no-op before GPR reads, descriptor checks, allocation, faults, or payload effects.

## State effects

- For logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.
- Sequence arithmetic wraps modulo the selected element width. Only ValidRow zero participates.
- Every physical destination coordinate outside the one-row valid region is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, dimensions, TSize, direction, mask, destination-name, and allocation preflight precedes the private-GPR snapshots.
- The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, or a nonzero inapplicable B.DATR field raises Fault_TileLegality before allocation.
- An unrepresentable shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.
- PE_MASK zero completes as a strict no-op before every validation or effect.

## Examples

- BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
