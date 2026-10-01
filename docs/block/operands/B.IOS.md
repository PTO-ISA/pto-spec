<!-- GENERATED FROM: asl/block/operands/B.IOS.asl -->
# B.IOS

**Normative ASL source:** `asl/block/operands/B.IOS.asl`

Binds one ordered absolute Core-private Shared register S0..S63 as a source or destination with a common four-PE participation mode decoded to a fixed mask.

## Normative identity {#PTO-INST-BLOCK-B-IOS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-ios-purpose role=purpose -->
## What B.IOS contributes

`B.IOS` is a 32-bit block header command that binds one Shared Tile to the operation of the current block. A Shared Tile is one of 64 Core-private registers `S0` to `S63` that all four PEs of the Core can see. One `B.IOS` names the register, says whether it is a source or a new destination, and gives a PE participation mode.

`B.IOS` executes nothing by itself. It appends one record to the block's Shared bindings, and the selected operation consumes them when the block commits. See [Shared bindings](../model/operands/shared-bindings.md).

<!-- PTO-READER-BLOCK: block-b-ios-mechanism role=mechanism -->
## Placement and mechanism

A participating `B.IOS` must appear in the header of an active block, before the first body instruction. A block holds at most four Shared bindings, in encoded order, and the operation consumes them in its schema order.

The handler checks in this order: the SizeCode encoding, zero participation, placement, and then `BindBundleSharedIO`. That function requires the mask to be nonzero and equal to the mask of every Tile and Shared binding already recorded, rejects a Shared Tile ID that is already bound, and fills the first free entry. The next non-modifier header command closes the range group that a following `B.SUBVIEW` or `B.ASSEMBLE` may modify.

Design point: one Shared Tile ID may appear only once per block. Every recorded entry therefore names a distinct Shared Tile, and no block can bind the same `Sx` as both a source and a destination.

<!-- PTO-READER-BLOCK: block-b-ios-inputs role=inputs-outputs -->
## Fields and encoded values

- `SharedTileID` (bits 25:20) names `S0` to `S63` directly. Code zero names `S0`; it does not mean absence.
- `SizeCode` (bits 18:15) is 0 for a source. Codes 1 to 12 make a destination of 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, or 256 KiB. Codes 13 to 15 are reserved.
- `PEMode` (bits 11:9) uses the same table as `B.IOT`: `000` none, `001` PE0, `010` PE1, `011` PE2, `100` PE3, `101` PE0 and PE1, `110` PE0 to PE2, `111` all four.
- Bits 31:26 and bit 19 are fixed at zero.

Design point: the Shared capacity is the size of one complete Core-wide object in the 256 KiB Shared pool. Unlike `B.IOT`, it is not multiplied by the number of participating PEs. `PEMode` selects which PEs issue or consume the binding; it does not assign payload quarters or offsets to them.

<!-- PTO-READER-BLOCK: block-b-ios-effects role=effects -->
## Pending state and publication

An accepted `B.IOS` changes only the pending Shared binding. A source binding is read-only: it never changes the Shared descriptor, allocation mask, initialized mask, or payload.

A destination written by a single PE publishes the complete Shared object when the operation succeeds. A destination with more than one participating PE must carry a `B.ASSEMBLE` modifier, in which each writer names an explicit non-overlapping range and LAST publishes the object.

Design point: `PEMode = 000` is a strict no-op after the `SizeCode` encoding check; codes 13 to 15 still raise `Fault_IllegalInstruction`. Inside a header it records zero participation and opens a zero-mode range group; it then skips placement, duplicate, schema, allocation, and descriptor checks and advances `TPC`. No record is appended.

<!-- PTO-READER-BLOCK: block-b-ios-constraints role=constraints -->
## Legality and fault boundary

- `SizeCode` 13 to 15, or a nonzero fixed bit, raises `Fault_IllegalInstruction`.
- A participating `B.IOS` outside an active header raises `Fault_BundleControl`.
- A mask that differs from an earlier Tile or Shared binding in the block raises `Fault_TileLegality`.
- A repeated Shared Tile ID, or a fifth Shared binding, raises `Fault_BundleControl`.
- A multi-PE destination without `B.ASSEMBLE` raises `Fault_TileLegality` before descriptor, payload, memory, or publication effects.

The architecture imposes no ordering between conflicting PE accesses to the same Shared payload offsets. Software avoids such conflicts or adds its own synchronization.

<!-- PTO-READER-BLOCK: block-b-ios-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOS S2, mask=1000
B.IOS mask=1000, ->S5<4KB>
```

Both records use `PEMode = 001`, so only PE0 participates and the masks agree. The first binds `S2` as a source with `SizeCode = 0` and encodes as `0x00201213`. The second makes `S5` a 4 KiB destination with `SizeCode = 6` and encodes as `0x00531213`. The destination has one writer, so it needs no `B.ASSEMBLE`. A third record `B.IOS S2, mask=1000` would raise `Fault_BundleControl`, because `S2` is already bound.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOS S<SharedTileID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTileID><SizeCode>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_ios_32_4ba5ef98fdaa | L32 | 32 | 0x00001013 / 0xfc0871ff | [{"field":"SizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_ios_32_4ba5ef98fdaa | SharedTileID | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_ios_32_4ba5ef98fdaa | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_ios_32_4ba5ef98fdaa | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_ios_32_4ba5ef98fdaa | SharedTileID | 6 | 0–63 | none | none | absolute Core-private Shared register S0 through S63, visible to all four PEs of that core | Encoded zero names S0; it does not mean absence. |
| b_ios_32_4ba5ef98fdaa | SizeCode | 4 | 0–12 | none | 13–15 | role and capacity: 0 source; 1..12 destination with 128 B..256 KiB for the complete Core-wide Shared object | Encoded zero selects a Shared source and never allocates. |
| b_ios_32_4ba5ef98fdaa | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOS a strict no-op. |

- `b_ios_32_4ba5ef98fdaa.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SharedTileID | absolute Core-private Shared register S0 through S63, visible to all four PEs of that core |
| SizeCode | role and capacity: 0 source; 1..12 destination with 128 B..256 KiB for the complete Core-wide Shared object |
| PEMode | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOS.asl -->
```asl
readonly func InstructionContractMatches_B_IOS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ios_32_4ba5ef98fdaa);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. A block may contain zero to four effective B.IOS instructions, ordered according to the selected operation schema.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOS.asl -->
```asl
pure func InstructionContractSharedIsSource_B_IOS(
    size_code: integer {0..12}) => boolean
begin
    return size_code == 0;
end;

pure func InstructionContractSharedCapacity_B_IOS(
    size_code: integer {1..12}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOS(
    size_code: integer {1..12}, pe_mask: bits(4)) => integer
begin
    return InstructionContractSharedCapacity_B_IOS(size_code);
end;

readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- S0 is an ordinary absolute Shared-register name. SizeCode=0 selects the source form; SizeCode=1..12 selects a destination capacity of 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, or 256 KiB for the complete Core-wide Shared object. Codes 13..15 are reserved.
- PEMode is a three-bit encoding expanded by the common profile decoder to the fixed four-PE semantic mask: 000 none, 001 PE0, 010 PE1, 011 PE2, 100 PE3, 101 PE0+PE1, 110 PE0+PE1+PE2, and 111 all four PEs.
- PEMode=000 decodes to no participating PE and is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks.

## Legality

- All SharedTileID codes 0..63 are assigned absolute Core-private Shared-register names S0..S63.
- SizeCode code 0 is the source role; destination codes 1..12 encode 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, and 256 KiB for the complete Core-wide Shared object. Codes 13..15 are reserved.
- The three-bit PEMode field accepts all eight encodings and the common profile decoder expands them exactly to the fixed four-PE semantic mask table. PEMode=000 is the strict no-effect source-bearing encoding.
- A participating B.IOS is legal only after BSTART and before the block body. At most four effective Shared bindings are accepted in encoded order.
- Two effective bindings in one block may not name the same Sx. The selected operation schema determines each ordered Shared operand role and must agree with SizeCode source/destination encoding.

## State effects

- The common PE-mode decoder expands PEMode once to the semantic four-PE mask used by every effective Shared binding.
- A zero decoded mask is a strict no-op. A source binding is read-only and never changes its Shared descriptor, allocation mask, initialized mask, or payload.
- A successful singleton destination publishes the complete Shared parent; a multi-PE destination uses B.ASSEMBLE with explicit non-overlapping ranges and atomic LAST publication.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Effective B.IOS bindings form one encoded-order stream of at most four operands. The selected operation consumes the stream in schema order.
- The architecture imposes no ordering between conflicting PE accesses to Shared payload offsets; software avoids conflicts or establishes separate synchronization.

## Exceptions

- Reserved instruction bits, SizeCode 13..15, and malformed field combinations raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOS outside an active header, a duplicate SharedTileID, or a fifth effective binding raises Illegal Block Exception before changing the stream.
- A mismatched effective decoded PE mask, incompatible destination descriptor, mask expansion, or operation-schema role mismatch raises Fault_TileLegality before Shared state changes.
- PEMode=000 is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault.

## Examples

- B.IOS S1, mask=0011
- B.IOS mask=1111, ->S63<0001>
