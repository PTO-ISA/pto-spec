<!-- GENERATED FROM: asl/block/operands/B.IOT.asl -->
# B.IOT

**Normative ASL source:** `asl/block/operands/B.IOT.asl`

Binds an ordered Local Tile source/destination sequence with one common four-PE participation mask; L terminates only that sequence and never releases a source.

## Normative identity {#PTO-INST-BLOCK-B-IOT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOT SrcTile0, mask=PE_MASK, <last>
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_iot_32_10db6db84f5d | L32 | 32 | 0x00005013 / 0xfc00707f | [{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},{"field":"TSize","operator":"one-of","values":[1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_2c07e7177fad | L32 | 32 | 0x00004013 / 0x00007e7f | [{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]}] |
| b_iot_32_8b8bce6bffe8 | L32 | 32 | 0x00004013 / 0x0000707f | [{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},{"field":"TSize","operator":"one-of","values":[1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_c11eb189dd83 | L32 | 32 | 0x00005013 / 0xfc007e7f | [{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]}] |
| b_iot_32_efa0fe3fe49a | L32 | 32 | 0x00006013 / 0xfff0707f | [{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},{"field":"TSize","operator":"one-of","values":[1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_10db6db84f5d | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_10db6db84f5d | PE_MASK | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_10db6db84f5d | TSize | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_10db6db84f5d | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_2c07e7177fad | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_2c07e7177fad | PE_MASK | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_8b8bce6bffe8 | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_8b8bce6bffe8 | PE_MASK | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_8b8bce6bffe8 | TSize | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_c11eb189dd83 | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_c11eb189dd83 | PE_MASK | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_efa0fe3fe49a | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_efa0fe3fe49a | PE_MASK | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_efa0fe3fe49a | TSize | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | Encoded zero supplies numeric zero for the first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16. |
| b_iot_32_10db6db84f5d | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_10db6db84f5d | PE_MASK | 4 | 0–15 | none | none | four-PE predicate shared by every effective binding in the block | Encoded zero selects no participating PE and makes B.IOT a strict no-op. |
| b_iot_32_10db6db84f5d | TSize | 3 | 1–7 | none | 0 | per-participating-PE destination capacity code: 1..7 encode 128 B..8 KiB | Encoded zero is reserved in every destination form; source-only forms do not encode TSize. |
| b_iot_32_10db6db84f5d | DstTile | 2 | 0–3 | none | none | destination hand selector: 0 T, 1 U, 2 M, or 3 N | Encoded zero supplies numeric zero for the destination hand selector: 0 T, 1 U, 2 M, or 3 N. |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | 0–63 | none | none | second ordered relative Local source in the same 64-entry queue namespace | Encoded zero supplies numeric zero for the second ordered relative Local source in the same 64-entry queue namespace. |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | Encoded zero supplies numeric zero for the first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16. |
| b_iot_32_2c07e7177fad | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_2c07e7177fad | PE_MASK | 4 | 0–15 | none | none | four-PE predicate shared by every effective binding in the block | Encoded zero selects no participating PE and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | 0–63 | none | none | second ordered relative Local source in the same 64-entry queue namespace | Encoded zero supplies numeric zero for the second ordered relative Local source in the same 64-entry queue namespace. |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | Encoded zero supplies numeric zero for the first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16. |
| b_iot_32_8b8bce6bffe8 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_8b8bce6bffe8 | PE_MASK | 4 | 0–15 | none | none | four-PE predicate shared by every effective binding in the block | Encoded zero selects no participating PE and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | TSize | 3 | 1–7 | none | 0 | per-participating-PE destination capacity code: 1..7 encode 128 B..8 KiB | Encoded zero is reserved in every destination form; source-only forms do not encode TSize. |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | 0–3 | none | none | destination hand selector: 0 T, 1 U, 2 M, or 3 N | Encoded zero supplies numeric zero for the destination hand selector: 0 T, 1 U, 2 M, or 3 N. |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | Encoded zero supplies numeric zero for the first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16. |
| b_iot_32_c11eb189dd83 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_c11eb189dd83 | PE_MASK | 4 | 0–15 | none | none | four-PE predicate shared by every effective binding in the block | Encoded zero selects no participating PE and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_efa0fe3fe49a | PE_MASK | 4 | 0–15 | none | none | four-PE predicate shared by every effective binding in the block | Encoded zero selects no participating PE and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | TSize | 3 | 1–7 | none | 0 | per-participating-PE destination capacity code: 1..7 encode 128 B..8 KiB | Encoded zero is reserved in every destination form; source-only forms do not encode TSize. |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | 0–3 | none | none | destination hand selector: 0 T, 1 U, 2 M, or 3 N | Encoded zero supplies numeric zero for the destination hand selector: 0 T, 1 U, 2 M, or 3 N. |

- `b_iot_32_10db6db84f5d.TSize` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_8b8bce6bffe8.TSize` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_efa0fe3fe49a.TSize` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcTile0 | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 |
| SrcTile1 | second ordered relative Local source in the same 64-entry queue namespace |
| L | effective-binding sequence terminator; not a source-lifetime marker |
| PE_MASK | four-PE predicate shared by every effective binding in the block |
| TSize | per-participating-PE destination capacity code: 1..7 encode 128 B..8 KiB |
| DstTile | destination hand selector: 0 T, 1 U, 2 M, or 3 N |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOT.asl -->
```asl
readonly func InstructionContractMatches_B_IOT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_iot_32_10db6db84f5d) ||
           (operation == CommandOperation_b_iot_32_2c07e7177fad) ||
           (operation == CommandOperation_b_iot_32_8b8bce6bffe8) ||
           (operation == CommandOperation_b_iot_32_c11eb189dd83) ||
           (operation == CommandOperation_b_iot_32_efa0fe3fe49a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. One or more effective B.IOT instructions form an ordered sequence whose final effective instruction has L=1.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOT.asl -->
```asl
// Complete-bundle matrix consumers use the compact Local stream documented by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and
// spec/evidence/bundle-command-totality.json: existing mathematical sources,
// optional RowMaxIn, vector QuantParam, vector PReLUParam, then D followed by
// optional RowMaxOut and GroupMaxOut.  The carrier is bounded at eight source
// and three destination ordinals; static operation catalogs remain unchanged.
pure func InstructionContractCompleteBundleLocalSourceCapacity_B_IOT() => integer
begin
    return 8;
end;

pure func InstructionContractCompleteBundleLocalDestinationCapacity_B_IOT() => integer
begin
    return 3;
end;

pure func InstructionContractZeroMaskIsNoOp_B_IOT(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractHasMaskOnlySharedCompanion_B_IOT() => boolean
begin
    return FALSE;
end;

pure func InstructionContractPerPECapacity_B_IOT(
    size_code: integer {1..7}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOT(
    size_code: integer {1..7}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOT(size_code));
end;

readonly func InstructionContractHandler_B_IOT() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleTileIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- PE_MASK=0000 is a strict no-op even when placement or downstream schema would otherwise reject; destination forms require TSize 1 through 7, and omitted source or destination roles are determined only by the selected encoding form.

## Legality

- b_iot_32_10db6db84f5d.PE_MASK accepts only 0..15; all other encodings are reserved.
- b_iot_32_10db6db84f5d.TSize accepts only 1..7; all other encodings are reserved.
- b_iot_32_10db6db84f5d.DstTile accepts only 0..3; all other encodings are reserved.
- b_iot_32_2c07e7177fad.PE_MASK accepts only 0..15; all other encodings are reserved.
- b_iot_32_8b8bce6bffe8.PE_MASK accepts only 0..15; all other encodings are reserved.
- b_iot_32_8b8bce6bffe8.TSize accepts only 1..7; all other encodings are reserved.
- b_iot_32_8b8bce6bffe8.DstTile accepts only 0..3; all other encodings are reserved.
- b_iot_32_c11eb189dd83.PE_MASK accepts only 0..15; all other encodings are reserved.
- b_iot_32_efa0fe3fe49a.PE_MASK accepts only 0..15; all other encodings are reserved.
- b_iot_32_efa0fe3fe49a.TSize accepts only 1..7; all other encodings are reserved.
- b_iot_32_efa0fe3fe49a.DstTile accepts only 0..3; all other encodings are reserved.
- Exactly five B.IOT forms are accepted: source0+destination, source0+source1, source0+source1+destination, source0, and destination-only.
- Source codes 0..63 name the relative queue namespace T#1..T#16, U#1..U#16, M#1..M#16, and N#1..N#16 in that order.
- Destination code 0..3 names the T, U, M, or N destination hand; the implementation allocates and renames a new physical Local Tile for that hand.
- Every nonzero effective Local or Shared binding in one block uses the same PE_MASK; a selected operation may impose a stricter mask.
- A participating B.IOT is legal only after BSTART and before the block body. No effective B.IOT may follow an L-marked binding.
- Only Local tile selectors are legal; destination TSize encodes 128 B through 8 KiB per participating PE and code zero is reserved.

## State effects

- Binds an ordered Local Tile source/destination sequence with one common four-PE participation mask; L terminates only that sequence and never releases a source.
- A source binding observes an existing Local Tile descriptor and remains allocated after the block. A destination binding allocates a new physical Local Tile, associates it with the selected destination hand, and does not expose PE_MASK to later consumers.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- B.IOT bindings are consumed in encoded order. L=1 closes the sequence after the current effective binding; a later effective B.IOT raises Illegal Block Exception before effects.

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOT outside an active header, a participating B.IOT after L, or an incomplete sequence raises Illegal Block Exception before binding or allocation.
- Mismatched nonzero masks, an illegal destination size, or operation-specific mask/schema violations raise Fault_TileLegality before tile effects.
- PE_MASK zero is a strict no-op before placement, stream, schema, allocation, descriptor, or downstream fault checks.

## Examples

- B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<TSize>

<!-- SUPPLEMENTARY-BEGIN -->
Destination TSize is a per-selected-PE capacity. Core allocation is the
embedded `InstructionContractCoreCapacity_B_IOT` result, namely
`popcount(PE_MASK)` equal per-PE allocations. PE_MASK does not partition one
Tile payload. Physical rows are derived from this per-PE capacity, data type,
and the power-of-two physical Col supplied by the block schema.
<!-- SUPPLEMENTARY-END -->
