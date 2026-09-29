<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red.asl -->
# Gm Atom Red

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the vocabulary of the GM atom/red family: the operation enumerations, the operation/type matrix, the per-element result rules, and the operand legality predicates. The execution bodies are in the GM atom/red execution unit.

- An atom form performs an atomic read-modify-write per lane and returns each old value in a destination Tile.
- A red (reduction) form performs the same kind of update but has no destination.

It also holds the NDF clauses for the legacy `MGATHER_CAS` spelling and for the family encoding, body schema, type legality, INC/DEC and POPC semantics, ordering, and faults.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-concepts role=concepts-state -->
## Concepts and visible state

`GMAtomicOperation` lists CAS, EXCH, MAX, MIN, ADD, INC, DEC, AND, OR, and XOR. `GMReductionOperation` lists MAX, MIN, ADD, INC, DEC, AND, OR, XOR, and POPC; it has no CAS or EXCH.

The accepted element types are fixed per operation:

| Operation | Accepted types |
| --- | --- |
| CAS (atom only) | U16, U32, U64 |
| EXCH (atom only) | U32, U64 |
| ADD | FP16, BF16, FP32, FP64, S32, U32, U64 |
| MAX, MIN | S32, S64, U32, U64 |
| AND, OR, XOR | U32, U64 |
| INC, DEC | U32 |
| POPC (red only) | U32 |

No four-bit or 8-bit type appears in this matrix.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-rules role=rules-interactions -->
## Rules and interactions

`GMAtomicResult` returns the new value and whether a write happens.

- CAS compares the old value with `expected` at element width (`GMRawElementValue`) and writes `replacement` only on a match; otherwise it reports no write.
- EXCH writes the new value unconditionally.
- Integer ADD adds the two element-width raw values; the later store truncates to the element width, so it wraps.
- MAX and MIN compare as signed for S32 and S64 and as unsigned otherwise.
- AND, OR, and XOR are bitwise.
- INC and DEC use `GMIncValue` and `GMDecValue` with the lane value as a limit.

Design point: INC and DEC are wrap-around counters with an explicit limit (NDF `PTO-ATOM-RED-INC-DEC-SEMANTICS-001`). INC returns 0 when the old value is at or above the limit. DEC returns the limit when the old value is 0 or above the limit. A counter therefore cycles inside `0..limit` instead of wrapping at the type width.

Floating ADD calls `GMFloatingAddPTX`, an implementation-defined hook. Its comment names the frozen PTX-derived profile: round to nearest even, no flush-to-zero for FP16 and BF16, and flush-to-zero for FP32 global atomics. The hook's model body adds the raw words and is not a floating addition.

The four `TileOperandsLegal_GM_*` predicates all require defined index contents and S32, U32, S64, or U64 indices. The CAS, VALUE, and red VALUE forms also require a legal type for the operation, the same data type on every data Tile they bind, and equal valid shape and layout across those Tiles; the two atom forms also require a legal destination descriptor. `TileOperandsLegal_GM_RED_POPC` checks only the index Tile.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-boundaries role=boundaries -->
## Architectural boundaries

The type matrix excludes Shared operands, vectors, packed FP16x2 and BF16x2, and U128 (NDF `PTO-ATOM-RED-TYPE-LEGALITY-001`). The block dispatcher rejects any other combination with `Fault_TileLegality` before effects.

These functions do not touch memory. Probing, ordering, duplicate-address serialization, and event recording belong to the execution unit and the architecture memory model.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-example role=example-usage -->
## Non-normative reading example

U32 INC with limit 3:

- old 0 gives 1, old 2 gives 3, old 3 gives 0, and old 7 gives 0.

U32 DEC with limit 3:

- old 0 gives 3, old 2 gives 1, and old 7 gives 3.

U32 ADD with old `0xFFFFFFFF` and value 2 computes `0x100000001`; the 4-byte store writes `0x00000001`.

S32 MAX with old `0xFFFFFFFF` (-1) and value 1 keeps 1, because the comparison is signed. U32 MAX with the same bits keeps `0xFFFFFFFF`.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-related role=related-owners-navigation -->
## Related owners

- [GM atom/red execution](gm-atom-red-execution.md) runs these rules against memory.
- [Atomics](atomics.md) owns the `MGATHER_CAS` body.
- [Addressing](addressing.md) owns the byte-displacement address.
- [Memory atomicity](../../../arch/memory-model/atomicity.md) owns atomic events.
- [Block GM atom/red dispatch](../../../block/model/dispatch/tlsu-gm-atom-red.md) owns the bundle schema checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","surface":"tile","classification":["model","memory","gm-atom-red"],"depends_on":["PTO-TILE-MODEL-MEMORY-ATOMICS","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"]}
// NDF-BEGIN: PTO-MGATHER-CAS-ATOMIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling aliases mgather.cas and MUST accept only
// U16, U32, and U64 transfer DataTypes. Each valid request MUST perform one
// atomic compare-and-swap at its signed or unsigned byte displacement and
// place the value observed by that request in the corresponding destination
// element. Duplicate-address requests MUST serialize in an implementation-
// defined order and MUST NOT expose a fixed row-major ordering requirement.
// NDF-END: PTO-MGATHER-CAS-ATOMIC-001
// NDF-BEGIN: PTO-MGATHER-CAS-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling MUST preflight every valid-region read and
// write address before its first atomic effect. On success it MUST publish
// one fully defined destination whose non-valid physical elements contain the
// selected pad value.
// NDF-END: PTO-MGATHER-CAS-PUBLICATION-001
// NDF-BEGIN: PTO-ATOM-RED-ENCODING-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TLSU Functions 8 through 27 select the GM atom/red family with the fixed
// low carrier 0x11181 and mask 0x07ffffff; 28 through 31 remain reserved.
// NDF-END: PTO-ATOM-RED-ENCODING-001
// NDF-BEGIN: PTO-ATOM-RED-BODY-SCHEMA-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Atom forms bind a destination-bearing Local B.IOT; red forms bind only
// source tiles. mscatter.popc has indices only and no ValueTile.
// NDF-END: PTO-ATOM-RED-BODY-SCHEMA-001
// NDF-BEGIN: PTO-ATOM-RED-TYPE-LEGALITY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The GM operation/type matrix is explicit and excludes Shared, vectors,
// packed f16x2/bf16x2, and U128.
// NDF-END: PTO-ATOM-RED-TYPE-LEGALITY-001
// NDF-BEGIN: PTO-ATOM-RED-INC-DEC-SEMANTICS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// INC and DEC are U32 limit operations: inc returns zero at or above the
// limit, while dec returns the limit for zero or above-limit old values.
// NDF-END: PTO-ATOM-RED-INC-DEC-SEMANTICS-001
// NDF-BEGIN: PTO-ATOM-RED-POPC-SEMANTICS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// mscatter.popc contributes one U32 increment per valid effective GM address and
// has no ValueTile or destination.
// NDF-END: PTO-ATOM-RED-POPC-SEMANTICS-001
// NDF-BEGIN: PTO-ATOM-RED-ORDERING-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every valid request is one intrinsic atomic event; duplicate effective
// addresses serialize in implementation-defined order and all are effective.
// All address probes complete before the first event or local publication.
// NDF-END: PTO-ATOM-RED-ORDERING-001
// NDF-BEGIN: PTO-ATOM-RED-FAULTS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Reserved encodings fault IllegalInstruction, unsupported tuples fault
// TileLegality, malformed bundles fault BundleControl, and alignment/page
// failures are preflighted before any architectural effect.
// NDF-END: PTO-ATOM-RED-FAULTS-001

type GMAtomicOperation of enumeration {
    GMAtomic_CAS,
    GMAtomic_EXCH,
    GMAtomic_MAX,
    GMAtomic_MIN,
    GMAtomic_ADD,
    GMAtomic_INC,
    GMAtomic_DEC,
    GMAtomic_AND,
    GMAtomic_OR,
    GMAtomic_XOR
};

type GMReductionOperation of enumeration {
    GMReduction_MAX,
    GMReduction_MIN,
    GMReduction_ADD,
    GMReduction_INC,
    GMReduction_DEC,
    GMReduction_AND,
    GMReduction_OR,
    GMReduction_XOR,
    GMReduction_POPC
};

pure func GMAtomicOperationDataTypeLegal(
    operation: GMAtomicOperation, data_type: TileDataType) => boolean
begin
    case operation of
        when GMAtomic_CAS =>
            return data_type == TileDataType_U16 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_EXCH =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_ADD =>
            return data_type == TileDataType_FP16 ||
                   data_type == TileDataType_BF16 ||
                   data_type == TileDataType_FP32 ||
                   data_type == TileDataType_FP64 ||
                   data_type == TileDataType_S32 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_INC, GMAtomic_DEC => return data_type == TileDataType_U32;
        when GMAtomic_MAX, GMAtomic_MIN =>
            return data_type == TileDataType_S32 ||
                   data_type == TileDataType_S64 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_AND, GMAtomic_OR, GMAtomic_XOR =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
    end;
end;

pure func GMReductionOperationDataTypeLegal(
    operation: GMReductionOperation, data_type: TileDataType) => boolean
begin
    case operation of
        when GMReduction_POPC => return data_type == TileDataType_U32;
        when GMReduction_INC, GMReduction_DEC => return data_type == TileDataType_U32;
        when GMReduction_ADD =>
            return data_type == TileDataType_FP16 ||
                   data_type == TileDataType_BF16 ||
                   data_type == TileDataType_FP32 ||
                   data_type == TileDataType_FP64 ||
                   data_type == TileDataType_S32 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMReduction_MAX, GMReduction_MIN =>
            return data_type == TileDataType_S32 ||
                   data_type == TileDataType_S64 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMReduction_AND, GMReduction_OR, GMReduction_XOR =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
    end;
end;

pure func GMIncValue(old: Word, limit: Word) => Word
begin
    if UInt(old) >= UInt(limit) then return Zeros{PTO_XLEN}; end;
    return old + Zeros{PTO_XLEN} + 1;
end;

pure func GMDecValue(old: Word, limit: Word) => Word
begin
    if UInt(old) == 0 || UInt(old) > UInt(limit) then return limit; end;
    return old - (Zeros{PTO_XLEN} + 1);
end;

readonly impdef func GMFloatingAddPTX(data_type: TileDataType, old: Word,
                             value: Word) => Word
begin
    // PTO GM floating ADD follows the frozen PTX-derived profile: RN-even;
    // FP16/BF16 no-FTZ, FP32 global-atomic FTZ, and the profile's explicit
    // NaN, infinity, signed-zero, overflow, and payload rules.
    return old + value;
end;

func GMAtomicResult(operation: GMAtomicOperation,
                         data_type: TileDataType, old: Word,
                         value: Word, expected: Word,
                         replacement: Word) => (Word, boolean)
begin
    case operation of
        when GMAtomic_CAS =>
            let matched = GMRawElementValue(old, data_type) ==
                GMRawElementValue(expected, data_type);
            if matched then return (GMRawElementValue(replacement, data_type), TRUE); end;
            return (old, FALSE);
        when GMAtomic_EXCH => return (GMRawElementValue(value, data_type), TRUE);
        when GMAtomic_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return (GMFloatingAddPTX(data_type, old, value), TRUE);
            end;
            return (GMRawElementValue(old, data_type) +
                    GMRawElementValue(value, data_type), TRUE);
        when GMAtomic_INC => return (GMIncValue(old, value), TRUE);
        when GMAtomic_DEC => return (GMDecValue(old, value), TRUE);
        when GMAtomic_AND => return (old AND value, TRUE);
        when GMAtomic_OR => return (old OR value, TRUE);
        when GMAtomic_XOR => return (old XOR value, TRUE);
        when GMAtomic_MAX =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) > SInt(value) then return (old, TRUE); else return (value, TRUE); end;
            end;
            if UInt(old) > UInt(value) then return (old, TRUE); else return (value, TRUE); end;
        when GMAtomic_MIN =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) < SInt(value) then return (old, TRUE); else return (value, TRUE); end;
            end;
            if UInt(old) < UInt(value) then return (old, TRUE); else return (value, TRUE); end;
    end;
end;

pure func GMRawElementValue(value: Word, data_type: TileDataType) => Word
begin
    return TileRawElementValue(value, data_type);
end;

readonly func TileOperandsLegal_GM_ATOM_CAS(
    operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    let data_type = _Tiles[[destination]].data_type;
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           _Tiles[[expected]].data_type == data_type &&
           _Tiles[[replacement]].data_type == data_type &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[expected]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[expected]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[replacement]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[replacement]].valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[expected]].layout &&
           _Tiles[[destination]].layout == _Tiles[[replacement]].layout;
end;

readonly func TileOperandsLegal_GM_ATOM_VALUE(
    operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
    value: TileIndex, pad_value: TilePadValue) => boolean
begin
    let data_type = _Tiles[[destination]].data_type;
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           _Tiles[[value]].data_type == data_type &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[value]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[value]].valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[value]].layout;
end;

readonly func TileOperandsLegal_GM_RED_VALUE(
    operation: GMReductionOperation, base_address: Word, indices: TileIndex, value: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMReductionOperationDataTypeLegal(
               operation, _Tiles[[value]].data_type) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[value]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[value]].valid_columns &&
           _Tiles[[indices]].layout == _Tiles[[value]].layout;
end;

readonly func TileOperandsLegal_GM_RED_POPC(
    operation: GMReductionOperation, base_address: Word, indices: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
