<!-- GENERATED FROM: asl/block/operands/B.IOT.asl -->
# B.IOT

**Normative ASL source:** `asl/block/operands/B.IOT.asl`

Bind ordered relative Local Tile sources and renamed destinations; each T/U/M/N #1 source names the newest published generation of that hand.

## Normative identity {#PTO-INST-BLOCK-B-IOT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-iot-purpose role=purpose -->
## What B.IOT contributes

`B.IOT` is a 32-bit block header command that binds Local Tiles to the operation of the current block. One `B.IOT` names up to two source Tiles, an optional new destination, a PE participation mode, and an `L` flag that ends the binding sequence. A Local Tile is a Tile register private to each PE.

`B.IOT` executes nothing by itself. It appends one record to the block's Tile bindings, and the selected operation reads the complete set when the block commits. See [Tile bindings](../model/operands/tile-bindings.md).

<!-- PTO-READER-BLOCK: block-b-iot-mechanism role=mechanism -->
## Placement and mechanism

A participating `B.IOT` must appear in the header of an active block, after the block start and before the first body instruction. Records are kept in encoded order. A record with `L = 1` closes the sequence, and a later participating `B.IOT` raises `Fault_BundleControl`.

The handler checks the SizeCode encoding first, then zero participation, then placement, then the PE mask, and then appends the record. A TGPR2T block additionally requires both of its `B.IOR` records before any participating `B.IOT`. Every encoded source is stored as a relative selector, and the next non-modifier header command closes the range group that a following `B.SUBVIEW` or `B.ASSEMBLE` may modify.

Design point: sources are resolved later, not by `B.IOT`. `ResolveBundleRelativeTileSources` maps each selector to a physical Tile during stage-2 preparation, before any destination is allocated. All sources therefore name the Tiles that the relative queues held before the operation, even when an earlier binding in the same block has a destination in the same hand.

<!-- PTO-READER-BLOCK: block-b-iot-inputs role=inputs-outputs -->
## Fields and encoded values

- `SrcTile0` (bits 25:20) and `SrcTile1` (bits 31:26) are 6-bit relative selectors. Bits 5:4 pick the hand T, U, M, or N, and bits 3:0 pick the distance. Distance 0 is the newest published Tile of that hand and is written `T#1`; distance 1 is `T#2`. Code zero therefore names `T#1`, not an absent source.
- `L` (bit 19) ends the binding sequence after this record. It does not end the lifetime of any source.
- `SizeCode` (bits 18:15) is 0 in source-only forms. Destination forms use 1 to 10 for 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, or 64 KiB per participating PE.
- `PEMode` (bits 11:9) expands to a four-PE mask: `000` none, `001` PE0, `010` PE1, `011` PE2, `100` PE3, `101` PE0 and PE1, `110` PE0 to PE2, `111` all four.
- `DstTile` (bits 8:7) selects the destination hand: 0 is T, 1 is U, 2 is M, 3 is N.

Design point: a destination names only a hand, never a register. The allocator chooses the physical Tile, and publication makes it `#1` of that hand. The capacity is charged to each selected PE, so the Core-wide total is the per-PE size times the number of participating PEs.

<!-- PTO-READER-BLOCK: block-b-iot-effects role=effects -->
## Pending state and publication

An accepted `B.IOT` changes only the pending binding record. It reads no Tile and allocates nothing.

After the block's operation succeeds, each destination that the block allocated without a `B.ASSEMBLE` modifier is published as the new `#1` of its hand. Older live Tiles of that hand shift one distance older, toward `#16`, and keep their descriptor and payload. Source Tiles stay allocated, because `B.IOT` never releases a source.

Design point: `PEMode = 000` is a strict no-op once the SizeCode encoding is valid. Inside a header it records zero participation and opens a zero-mode range group; it then skips placement, stream, schema, allocation, and descriptor checks and advances `TPC`. No record is appended.

<!-- PTO-READER-BLOCK: block-b-iot-constraints role=constraints -->
## Legality and fault boundary

- A source-only form with nonzero `SizeCode`, or a destination form with `SizeCode` 0 or 11 to 15, raises `Fault_IllegalInstruction`.
- A participating `B.IOT` outside an active header, or after the sequence is closed, raises `Fault_BundleControl`.
- A mask that differs from an earlier Tile binding in the same block raises `Fault_TileLegality`. The Tile-binding table holds 16 records; appending to a full table also raises `Fault_TileLegality`.
- A relative source that names no live allocated Tile raises `Fault_TileLegality` at stage-2 preparation, before source reads, allocation, or operation effects.

The operation schema decides how many records it accepts and which roles they carry. A mismatch raises the operation's legality fault at commit, before any destination effect.

<!-- PTO-READER-BLOCK: block-b-iot-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOT T#1, T#2, mask=1111, <last>, ->T<2KB>
```

This record binds the newest T Tile as the left source and the next older T Tile as the right source, with all four PEs and a 2 KiB destination per PE in hand T. Its fields are `SrcTile0 = 0`, `SrcTile1 = 1`, `L = 1`, `SizeCode = 5`, `PEMode = 111`, and `DstTile = 0`, which encode as `0x040ace13`. The Core-wide allocation is 4 x 2 KiB = 8 KiB. After a successful operation, the destination becomes `T#1`, the old `T#1` becomes `T#2`, and the old `T#2` becomes `T#3`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<SizeCode>
B.IOT SrcTile0, mask=PE_MASK, <last>
B.IOT mask=PE_MASK, <last>, ->DstTile<SizeCode>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_iot_32_10db6db84f5d | L32 | 32 | 0x00005013 / 0xfc00707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_2c07e7177fad | L32 | 32 | 0x00004013 / 0x0007f1ff | [{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |
| b_iot_32_8b8bce6bffe8 | L32 | 32 | 0x00004013 / 0x0000707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_c11eb189dd83 | L32 | 32 | 0x00005013 / 0xfc07f1ff | [{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |
| b_iot_32_efa0fe3fe49a | L32 | 32 | 0x00006013 / 0xfff0707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_10db6db84f5d | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_10db6db84f5d | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_10db6db84f5d | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_10db6db84f5d | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_2c07e7177fad | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_2c07e7177fad | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_8b8bce6bffe8 | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_8b8bce6bffe8 | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_8b8bce6bffe8 | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_c11eb189dd83 | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_c11eb189dd83 | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_efa0fe3fe49a | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_efa0fe3fe49a | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_efa0fe3fe49a | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_10db6db84f5d | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_10db6db84f5d | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_10db6db84f5d | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_10db6db84f5d | DstTile | 2 | 0–3 | none | none | destination hand selector whose publication pushes a new #1 generation | Code zero selects the T destination hand; successful publication pushes the new generation to T#1. |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | 0–63 | none | none | second relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_2c07e7177fad | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_2c07e7177fad | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | 0–63 | none | none | second relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_8b8bce6bffe8 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_8b8bce6bffe8 | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_8b8bce6bffe8 | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | 0–3 | none | none | destination hand selector whose publication pushes a new #1 generation | Code zero selects the T destination hand; successful publication pushes the new generation to T#1. |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_c11eb189dd83 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_c11eb189dd83 | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_efa0fe3fe49a | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_efa0fe3fe49a | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | 0–3 | none | none | destination hand selector whose publication pushes a new #1 generation | Code zero selects the T destination hand; successful publication pushes the new generation to T#1. |

- `b_iot_32_10db6db84f5d.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_8b8bce6bffe8.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_efa0fe3fe49a.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcTile0 | first relative Local source, newest-first within its encoded hand |
| SrcTile1 | second relative Local source, newest-first within its encoded hand |
| L | effective-binding sequence terminator; not a source-lifetime marker |
| SizeCode | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE |
| PEMode | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask |
| DstTile | destination hand selector whose publication pushes a new #1 generation |

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
    size_code: integer {1..10}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOT(
    size_code: integer {1..10}, pe_mask: bits(4)) => integer
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

- PEMode is a three-bit encoding expanded by the common profile decoder to the fixed four-PE semantic mask: 000 none, 001 PE0, 010 PE1, 011 PE2, 100 PE3, 101 PE0+PE1, 110 PE0+PE1+PE2, and 111 all four PEs.
- SizeCode=0 is the source-only encoding and never allocates; destination forms require SizeCode=1..10 for 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, and 64 KiB per participating PE.
- PEMode=000 decodes to no participating PE and is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks.
- T#1, U#1, M#1, and N#1 name the newest published generation in their hand; increasing indices select progressively older live generations. Direct model TileIndex values are resolved physical identities and are not encoded relative selectors.

## Legality

- The three-bit PEMode field accepts all eight encodings and the common profile decoder expands them exactly to the fixed four-PE semantic mask table.
- Source-only forms require SizeCode=0 and fix instruction bits 7..8 to zero; a non-zero value in those bits is reserved. Destination forms require SizeCode=1..10; codes 11..15 are reserved for Local B.IOT.
- PEMode=000 is accepted as the strict no-effect source-bearing encoding; a nonzero decoded mask is a four-PE predicate shared by every effective binding in the block.
- A participating B.IOT is legal only after BSTART and before the block body. At most four effective Local bindings are accepted in encoded order.
- The selected operation schema determines ordered Local source and destination roles and must agree with the form fields and SizeCode role.
- Every encoded Local source is resolved against the published pre-operation relative map. An unavailable relative generation raises Fault_TileLegality before source reads, allocation, or operation effects.

## State effects

- The common PE-mode decoder expands PEMode once to the semantic four-PE mask used by every effective Local binding.
- A zero decoded mask is a strict no-op. A successful source binding is read-only; a successful destination atomically updates selected payload quarters and a compatible persistent descriptor.
- The selected operation defines publication and ordering. Its first write fixes the allocation mask; later writes may update only a subset with a compatible descriptor and cannot expand the mask.
- Successful destination publication pushes a new generation at #1 of the selected T/U/M/N hand and shifts older live generations toward #16 without modifying their descriptor or payload.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Resolve all relative sources against the published pre-operation hand order before allocating or publishing any destination. Successful destinations publish in B.IOT order; each later same-hand destination becomes the newer #1 generation.
- B.IOT bindings are consumed in encoded order. L=1 closes the sequence after the current effective binding; a later effective B.IOT raises Illegal Block Exception before effects.

## Exceptions

- Reserved instruction bits and malformed field combinations raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOT outside an active header, a duplicate binding, a fifth effective binding, a role mismatch, or an unsupported SizeCode raises the applicable fault before changing the stream.
- A mismatched effective decoded PE mask, incompatible destination descriptor, mask expansion, or operation-schema mismatch raises Fault_TileLegality before tile state changes.
- PEMode=000 is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault.

## Examples

- B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>
