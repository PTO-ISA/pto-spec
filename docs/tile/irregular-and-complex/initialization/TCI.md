<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/TCI.asl -->
# TCI

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/TCI.asl`

Generate a typed integer sequence in a new Local Tile, retaining RowMajor and adding explicit CUBE_M16/CUBE_M32 forms.

## Normative identity {#PTO-INST-TILE-TCI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tci-purpose role=purpose -->
## What TCI does

`TCI` writes an integer index sequence into a newly allocated Local Tile. It reads no source Tile; the only inputs are a start value and a direction or step word taken from general-purpose registers (GPRs).

It has two forms. The RowMajor form writes one row. The CUBE form writes a two-dimensional pattern into a `CUBE_M16` or `CUBE_M32` Tile.

Design point: `TCI` is selected by `BSTART.SFU` with TEPL Mode 3 Function 6 (selector `0x066`) and has no standalone opcode. The CUBE form is selected only by an explicit `B.DATR` `Layout` of `CUBE_M32` (29) or `CUBE_M16` (31), so a bundle without that tuple always keeps the RowMajor form.

<!-- PTO-READER-BLOCK: tile-tci-mechanism role=mechanism -->
## Generation formula

Each generated value is truncated to the element width: only its low 16 or 32 bits are kept. Every sequence therefore wraps modulo the element width instead of faulting or saturating.

RowMajor form: logical column k receives `start + k` when the direction is ascending (0) and `start - k` when it is descending (1). Only row 0 is valid.

CUBE form: the second GPR is a packed Step2D word. Bits 63 to 32 hold the signed RowStep and bits 31 to 0 hold the signed ColStep; each must be -1, 0, or +1. Element (r, c) receives `trunc_W(Start + r*RowStep + c*ColStep)`, written through the CUBE cell mapping.

Design point: the arithmetic is raw carrier arithmetic followed by truncation. A U16 ascending sequence that passes 65535 continues at 0, and no numeric status is recorded.

The CUBE form consults the ExecutionMask: an active coordinate receives the generated value, and an inactive one receives the mask's zero or merge value. [Generation execution](../../model/execution/generation.md) owns both helpers.

<!-- PTO-READER-BLOCK: tile-tci-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` is a newly allocated Local `S32`, `S16`, `U32`, or `U16` Tile.
- `scalar0` is the start value, read from the GPR named by RegSrc0.
- `flag0` is the RowMajor direction or the CUBE Step2D word, read from the GPR named by RegSrc1.

RowMajor shape: `B.DIM` LB0 is required and gives a nonzero ValidCol. LB1 defaults to 1, and an explicit LB1 must also equal 1. LB2 defaults to Col = ValidCol. Omitting `B.IOR` selects start 0 and ascending direction; an explicit all-zero `B.IOR` gives the same values.

CUBE shape: LB1 gives a positive ValidRow, at most 16 for `CUBE_M16`. An explicit LB2 is the exact physical Col and must be aligned to the cell column quantum; an omitted LB2 aligns ValidCol up to that quantum. The present `B.DATR` must use `DataType=DTYPE_NONE` with Pad, CMode, RMode, Sat, and Canonicalize all 0, and exactly one `B.IOR` must name StartGPR, Step2DGPR, zero, and `->zero`.

The destination keeps the `BSTART` data type. Exactly one terminating `B.IOT` is legal: it is destination-only unless a PredicateCell supplies the ExecutionMask, in which case the same `B.IOT` must also bind that predicate Tile as its source. A second `B.IOT`, `B.IOS`, or any other source binding is illegal.

<!-- PTO-READER-BLOCK: tile-tci-effects role=effects -->
## Publication, definedness, and padding

The sequence payload, the destination descriptor, and the definedness of every element publish as one operation. Every valid element becomes defined.

Physical elements outside the valid region receive `Null` padding: they hold a zero carrier but stay undefined. `TCI` carries no `PadValue`, so a later definedness check does not treat padding as generated data.

`TCI` has no global-memory effect, writes no GPR, and records no numeric status. A rejected bundle publishes nothing.

<!-- PTO-READER-BLOCK: tile-tci-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data types are `S32`, `S16`, `U32`, and `U16`.

- RowMajor form: a malformed binding, `B.IOS`, an unsupported type, a missing or invalid dimension, a direction other than 0 or 1, or a nonzero inapplicable `B.DATR` field raises `Fault_TileLegality`.
- CUBE form: a malformed command or `B.IOR` structure raises `Fault_BundleControl`; an invalid selector, tuple, dimension, step, or alignment raises `Fault_TileLegality`; a legal geometry with too small a TSize or exhausted Tile capacity raises `Fault_TileAllocation`.
- `PE_MASK=0000` is a strict no-op after the `B.IOT` size-code encoding check: no schema validation, GPR read, allocation, or operation fault follows, but an illegal `B.IOT` size code still raises `Fault_IllegalInstruction`.

Every rejection happens before allocation or publication, so a fault leaves no partial sequence.

<!-- PTO-READER-BLOCK: tile-tci-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

A U16 RowMajor destination has 4 valid columns, the start register holds `0x1fffe`, and the direction is ascending. The start is truncated to 65534, so the row is 65534, 65535, 0, 1; the third value is 65536 truncated to 16 bits.

A U16 `CUBE_M16` destination has ValidRow 2 and ValidCol 3, start 5, and Step2D `0xFFFFFFFF00000001`, which is RowStep -1 and ColStep +1. Row 0 is 5, 6, 7 and row 1 is 4, 5, 6.

In macro form, a 64-element U32 sequence with the default start and direction is written below. The 256B destination holds 64 x 4 = 256 bytes.

```text
TCI <Row=1, Col=64, U32>, ->T<256B>
```
<!-- SUPPLEMENTARY-END -->

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
| scalar0 | typed sequence start from RowMajor/CUBE RegSrc0 |
| flag0 | RowMajor direction or CUBE packed Step2D from RegSrc1 |

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
B.DATR RowMajor all-zero (optional), or explicit CUBE_M32/CUBE_M16 tuple
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (RowMajor optional, default 1; when present must equal 1; CUBE required positive)
B.DIM LB2=Col (RowMajor optional, default ValidCol; CUBE optional; omitted aligns ValidCol to the cell-column quantum)
RowMajor: B.IOR Start, Direction (optional; omission selects 0 and ascending)
CUBE: exactly one B.IOR StartGPR, Step2DGPR, zero, ->zero
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

- RowMajor retains the existing defaults: LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.
- CUBE is selected only by explicit B.DATR Layout=CUBE_M32 (29) or CUBE_M16 (31); its present B.DATR must use DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, and Canonicalize=0.
- CUBE omitted LB2 selects Col=align_up(ValidCol, TileCubeCellColumns(Layout, DataType)); explicit Col is never rounded. CUBE requires one canonical B.IOR with StartGPR, packed Step2DGPR, zero, and ->zero. Physical padding is always Null.

## Legality

- TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.
- The selected DataType is exactly S32, S16, U32, or U16. The existing RowMajor form remains one-row with ValidRow one, ValidCol nonzero, and Col at least ValidCol.
- The CUBE form is selected only by explicit Layout CUBE_M32 (29) or CUBE_M16 (31), uses a Matrix-location Local numeric destination, and retains one exact TileInfo.columns physical Col independently of ValidCol.
- CUBE M16 requires ValidRow>0 and ValidRow<=16; CUBE M32 accepts every positive ValidRow. Both forms require ValidCol<=Col and a cell-column-aligned explicit Col.
- CUBE B.DATR is exactly {Layout=CUBE_M32/CUBE_M16, DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, Canonicalize=0}.
- CUBE B.IOR is exactly StartGPR, packed Step2DGPR with signed s32 RowStep in bits [63:32] and signed s32 ColStep in bits [31:0], then zero and ->zero. Each step is exactly -1, 0, or +1.
- For every logical [0,ValidRow) x [0,ValidCol), CUBE writes trunc_W(Start + r*RowStep + c*ColStep) through the physical CELL mapping. TCI.COL and TCI.ROW spellings are reader-only aliases for the four unit-step tuples and do not add an opcode, selector, or catalog identity.
- PE_MASK zero is a strict no-op before GPR reads, validation, allocation, faults, or payload effects.

## State effects

- For RowMajor logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.
- RowMajor sequence arithmetic wraps modulo the selected element width; only its ValidRow=1 row participates.
- For CUBE, sequence arithmetic wraps modulo the selected element width over the logical rectangle [0,ValidRow) x [0,ValidCol).
- For RowMajor, every physical destination coordinate outside the one-row valid region is undefined Null padding.
- For CUBE, every physical destination coordinate outside the valid rectangle is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, form/type, dimensions, exact CUBE Col, TSize, step/selector, mask, destination-name, and capacity preflight precedes private-GPR snapshots.
- The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- RowMajor keeps the existing Fault_TileLegality rules for malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, and nonzero inapplicable B.DATR fields.
- CUBE malformed command/B.IOR structure raises Fault_BundleControl; invalid selectors, tuple, dimensions, steps, alignment, or representability raise Fault_TileLegality; a legal CUBE geometry with insufficient explicit TSize or exhausted Tile capacity raises Fault_TileAllocation. All reject before allocation/publication.
- PE_MASK zero completes as a strict no-op before every validation, GPR read, descriptor check, allocation, fault, and payload effect.

## Examples

- BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
- BSTART.SFU TCI, U16; B.DATR CUBE_M16, DTYPE_NONE, 0, 0, 0, 0, 0; B.DIM LB0=3; B.DIM LB1=2; B.DIM LB2=4; B.IOR StartGPR, Step2DGPR, zero, ->zero; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
