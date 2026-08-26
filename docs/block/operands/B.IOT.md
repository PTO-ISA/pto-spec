<!-- GENERATED FROM: asl/block/operands/B.IOT.asl -->
# B.IOT

**Normative ASL source:** `asl/block/operands/B.IOT.asl`

Binds an ordered Local Tile source/destination sequence with one common four-PE participation mode decoded to a fixed mask; L terminates only that sequence and never releases a source.

## Normative identity {#PTO-INST-BLOCK-B-IOT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-iot-purpose role=purpose -->
## What B.IOT contributes

`B.IOT` is a 32-bit block header command that records ordered Local tile sources and destinations for the selected block operation. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-iot-mechanism role=mechanism -->
## Placement and mechanism

The command belongs to an active header before the first body instruction. Its effective order and arity are checked against the completed operation schema rather than inferred from this command in isolation.

The common PE-mode decoder forms the four-PE mask once. A zero mask is a strict no-op; an effective Local source is read-only, while an effective destination is recorded for atomic publication after complete validation.

<!-- PTO-READER-BLOCK: block-b-iot-inputs role=inputs-outputs -->
## Operands and header roles

- `SrcTile0` selects the first ordered Local source; its exact assigned domain remains in the generated contract below.
- `SrcTile1` selects the second ordered Local source; its exact assigned domain remains in the generated contract below.
- `L` terminates the effective Local-binding sequence; its exact assigned domain remains in the generated contract below.
- `SizeCode` selects source-only or destination capacity; its exact assigned domain remains in the generated contract below.
- `PEMode` encodes the participating-PE mode; its exact assigned domain remains in the generated contract below.
- `DstTile` selects the Local destination hand; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-iot-effects role=effects -->
## Pending state and completion

An accepted header command changes only its pending record or carrier. Architectural tile, Shared, GPR, memory, and completion effects remain deferred to the completed block unless this owner's contract explicitly identifies an immediate header-state update.

<!-- PTO-READER-BLOCK: block-b-iot-constraints role=constraints -->
## Legality and fault boundary

The contract separates raw decode failures, header-stream errors, and tile-legality failures. Zero-mask bindings bypass downstream schema, duplicate, allocation, descriptor, and memory checks as a strict no-op.

<!-- PTO-READER-BLOCK: block-b-iot-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>
```

Assume an active compatible header with no earlier conflicting `B.IOT` command. Placing `B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>` at the next header slot records this command's pending fields; it does not by itself execute the eventual body operation.
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
| b_iot_32_2c07e7177fad | L32 | 32 | 0x00004013 / 0x0007f07f | [{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |
| b_iot_32_8b8bce6bffe8 | L32 | 32 | 0x00004013 / 0x0000707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_c11eb189dd83 | L32 | 32 | 0x00005013 / 0xfc07f07f | [{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |
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
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 |
| b_iot_32_10db6db84f5d | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_10db6db84f5d | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_10db6db84f5d | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_10db6db84f5d | DstTile | 2 | 0–3 | none | none | destination hand selector: 0 T, 1 U, 2 M, or 3 N | destination hand selector: 0 T, 1 U, 2 M, or 3 N |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | 0–63 | none | none | second ordered relative Local source in the same 64-entry queue namespace | second ordered relative Local source in the same 64-entry queue namespace |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 |
| b_iot_32_2c07e7177fad | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_2c07e7177fad | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | 0–63 | none | none | second ordered relative Local source in the same 64-entry queue namespace | second ordered relative Local source in the same 64-entry queue namespace |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 |
| b_iot_32_8b8bce6bffe8 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_8b8bce6bffe8 | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_8b8bce6bffe8 | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | 0–3 | none | none | destination hand selector: 0 T, 1 U, 2 M, or 3 N | destination hand selector: 0 T, 1 U, 2 M, or 3 N |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | 0–63 | none | none | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 |
| b_iot_32_c11eb189dd83 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_c11eb189dd83 | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_efa0fe3fe49a | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_efa0fe3fe49a | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | 0–3 | none | none | destination hand selector: 0 T, 1 U, 2 M, or 3 N | destination hand selector: 0 T, 1 U, 2 M, or 3 N |

- `b_iot_32_10db6db84f5d.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_8b8bce6bffe8.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_efa0fe3fe49a.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcTile0 | first ordered relative Local source: T#1..T#16, U#1..U#16, M#1..M#16, or N#1..N#16 |
| SrcTile1 | second ordered relative Local source in the same 64-entry queue namespace |
| L | effective-binding sequence terminator; not a source-lifetime marker |
| SizeCode | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE |
| PEMode | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask |
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
    size_code: integer {1..12}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOT(
    size_code: integer {1..12}, pe_mask: bits(4)) => integer
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
- SizeCode=0 is the source-only encoding and never allocates; destination forms require SizeCode=1..10 for 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, and 256 KiB per participating PE.
- PEMode=000 decodes to no participating PE and is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks.

## Legality

- The three-bit PEMode field accepts all eight encodings and the common profile decoder expands them exactly to the fixed four-PE semantic mask table.
- Source-only forms require SizeCode=0. Destination forms require SizeCode=1..10; codes 11..15 are reserved for Local B.IOT.
- PEMode=000 is accepted as the strict no-effect source-bearing encoding; a nonzero decoded mask is a four-PE predicate shared by every effective binding in the block.
- A participating B.IOT is legal only after BSTART and before the block body. At most four effective Local bindings are accepted in encoded order.
- The selected operation schema determines ordered Local source and destination roles and must agree with the form fields and SizeCode role.

## State effects

- The common PE-mode decoder expands PEMode once to the semantic four-PE mask used by every effective Local binding.
- A zero decoded mask is a strict no-op. A successful source binding is read-only; a successful destination atomically updates selected payload quarters and a compatible persistent descriptor.
- The selected operation defines publication and ordering. Its first write fixes the allocation mask; later writes may update only a subset with a compatible descriptor and cannot expand the mask.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- B.IOT bindings are consumed in encoded order. L=1 closes the sequence after the current effective binding; a later effective B.IOT raises Illegal Block Exception before effects.

## Exceptions

- Reserved instruction bits and malformed field combinations raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOT outside an active header, a duplicate binding, a fifth effective binding, a role mismatch, or an unsupported SizeCode raises the applicable fault before changing the stream.
- A mismatched effective decoded PE mask, incompatible destination descriptor, mask expansion, or operation-schema mismatch raises Fault_TileLegality before tile state changes.
- PEMode=000 is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault.

## Examples

- B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>
