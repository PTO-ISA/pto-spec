<!-- GENERATED FROM: asl/block/operands/B.ASSEMBLE.asl -->
# B.ASSEMBLE

**Normative ASL source:** `asl/block/operands/B.ASSEMBLE.asl`

Decodes one writer-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.

## Normative identity {#PTO-INST-BLOCK-B-ASSEMBLE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-assemble-purpose role=purpose -->
## What B.ASSEMBLE contributes

`B.ASSEMBLE` is a 32-bit header command that turns the destination of the binder just before it into one writer of a multi-block build. The binder is a `B.IOT` or `B.IOS`. A build of this kind is called a generation: one parent Tile is written in ranges by several blocks, or by several PEs, and is published once, at LAST.

Like `B.SUBVIEW`, the command is a range modifier. It attaches to its binder and records fields; it allocates nothing when it executes. See [Range modifiers](../model/operands/range-modifiers.md), [Local generation](../model/operands/local-generation.md), and [Shared generation](../model/operands/shared-generation.md).

<!-- PTO-READER-BLOCK: block-b-assemble-mechanism role=mechanism -->
## Phases and mechanism

`INIT` and `LAST` select one of four phases:

- INIT (`INIT = 1`, `LAST = 0`) starts a generation. The binder's destination `SizeCode` becomes the parent capacity, and the parent is allocated.
- MIDDLE (`INIT = 0`, `LAST = 0`) adds one writer to an open generation.
- LAST (`INIT = 0`, `LAST = 1`) adds the final writer and closes the generation.
- INIT_LAST (`INIT = 1`, `LAST = 1`) starts and closes a generation in one block.

A continuation (MIDDLE or LAST) names the parent differently on each surface. For Local Tiles the binder has no destination, and the final source slot of the binder becomes the parent reference instead of a data source. For Shared Tiles the final `B.IOS` with `SizeCode = 0` is reused as the destination of the open generation.

Design point: a Local parent is named by an ordinary relative selector such as `T#1`. INIT publishes the parent into the ordinary relative queue, and no private assemble namespace exists. A continuation therefore finds the parent the same way any source finds a Tile.

<!-- PTO-READER-BLOCK: block-b-assemble-inputs role=inputs-outputs -->
## Fields and encoded values

- `INIT` (bit 31) selects INIT or INIT_LAST when 1, and MIDDLE or LAST when 0.
- `uimm11` (bits 30:20) is an unsigned addend, zero-extended. Zero is a real zero.
- `RegSrc` (bits 19:15) names an absolute GPR 0 to 23. Code zero names the zero GPR.
- `LAST` (bit 11) marks the final writer.
- `WriterSizeCode` (bits 10:7) is the size of this writer's range: 1 to 10 for a Local group and 1 to 12 for a Shared group, from 128 B upward. Raw codes 13 to 15 are reserved.

The writer offset is `GPR[RegSrc] + uimm11` modulo 2^XLEN, counted in 128-byte CELLs of the parent. The handler stores the raw fields and this offset in the destination's range record.

Design point: `WriterSizeCode` is the size of the current writer in every phase, never the parent size. The parent capacity comes from the INIT binder's `SizeCode`, so one parent can be filled by several smaller writers whose ranges must fit inside it and must not overlap on a shared PE.

<!-- PTO-READER-BLOCK: block-b-assemble-effects role=effects -->
## Recorded state and publication

An accepted `B.ASSEMBLE` changes only the binder's range record, and for a Local continuation it moves the final source into the parent reference. It reads no Tile payload.

After the operation succeeds, the writer's CELLs are marked covered. At LAST the generation closes. It is marked published only when every participating PE is eligible, which requires every required CELL to be covered and also ready for that PE.

Design point: a zero-participation binder (`PEMode = 000`) opens a zero-mode group. There, each raw-legal `B.ASSEMBLE` passes only the open-group check, reads no GPR, and records nothing.

<!-- PTO-READER-BLOCK: block-b-assemble-constraints role=constraints -->
## Legality and fault boundary

- A `RegSrc` code 24 to 31, a raw `WriterSizeCode` 13 to 15, or a nonzero fixed bit raises `Fault_IllegalInstruction` before any GPR read.
- `WriterSizeCode` 11 or 12 attached to a participating Local group raises `Fault_TileLegality`.
- No open group, INIT on a binder without an unused destination role, a continuation on a binder that has a destination, or a writer size code of 0 in a participating group raises `Fault_BundleControl`.
- At stage-2 preparation, a range outside the parent, a range that overlaps an earlier writer on a shared PE, a writer mask that is not a subset of the generation's mask, or a parent reference that names no open generation raises a fault before the operation's effects.
- A Shared destination with more than one participating PE and no `B.ASSEMBLE` raises `Fault_TileLegality`.

<!-- PTO-READER-BLOCK: block-b-assemble-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOT T#2, mask=1111, <last>, ->T<4KB>
B.ASSEMBLE 1, 0, zero, 0, 5
```

This block starts a Local generation. The binder's `SizeCode` 6 makes a 4 KiB parent, which is 32 CELLs. The modifier is INIT, not LAST, with offset 0 + 0 = 0 and writer size code 5, which is 2 KiB or 16 CELLs, and encodes as `0x800012d3`. After commit, CELLs 0 to 15 are covered and the parent is the new `T#1`. A later block `B.IOT T#2, T#1, mask=1111, <last>` followed by `B.ASSEMBLE 0, 1, zero, 16, 5` (encoded `0x01001ad3`) uses `T#1` as the parent reference, writes CELLs 16 to 31 from its source `T#2`, and closes the generation. An offset of 8 in that second block would overlap CELLs 8 to 15 and fault.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.ASSEMBLE INIT, LAST, RegSrc, uimm11, WriterSizeCode
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_assemble_32_122000000002 | L32 | 32 | 0x00001053 / 0x0000707f | [{"field":"INIT","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"WriterSizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_assemble_32_122000000002 | INIT | 1 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":1}] |
| b_assemble_32_122000000002 | uimm11 | 11 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":11}] |
| b_assemble_32_122000000002 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_assemble_32_122000000002 | LAST | 1 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":1}] |
| b_assemble_32_122000000002 | WriterSizeCode | 4 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_assemble_32_122000000002 | INIT | 1 | 0–1 | none | none | selects INIT versus MIDDLE/LAST form | Zero selects MIDDLE/LAST rather than INIT/INIT_LAST. |
| b_assemble_32_122000000002 | uimm11 | 11 | 0–2047 | none | none | unsigned XLEN addend | Zero is a real zero displacement. |
| b_assemble_32_122000000002 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR selector | Zero names the architectural zero GPR. |
| b_assemble_32_122000000002 | LAST | 1 | 0–1 | none | none | marks the final assembler carrier | One closes the modifier sequence at the semantic assembler. |
| b_assemble_32_122000000002 | WriterSizeCode | 4 | 0–12 | none | 13–15 | current writer extent code | Zero is reserved for discarded groups; participating writers require a nonzero extent. |

- `b_assemble_32_122000000002.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_assemble_32_122000000002.WriterSizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| INIT | selects INIT versus MIDDLE/LAST form |
| LAST | marks the final assembler carrier |
| RegSrc | absolute GPR selector |
| uimm11 | unsigned XLEN addend |
| WriterSizeCode | current writer extent code |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.ASSEMBLE.asl -->
```asl
readonly func InstructionContractMatches_B_ASSEMBLE(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_assemble_32_122000000002;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.ASSEMBLE.asl -->
```asl
pure func InstructionContractWriterSizeCodeIsRawLegal_B_ASSEMBLE(code: integer {0..15}) => boolean
begin
    return code <= 12;
end;

readonly func InstructionContractHandler_B_ASSEMBLE() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleAssemble;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR. INIT=0 encodes MIDDLE/LAST; INIT=1 encodes INIT/INIT_LAST.

## Legality

- RegSrc accepts only absolute GPR selectors 0..23.
- WriterSizeCode raw values 0..12 are decoded; raw values 13..15 are reserved and raise Fault_IllegalInstruction; INIT/size combinations select INIT, MIDDLE, LAST, or INIT_LAST and contradictory combinations are BundleControl.
- Local WriterSizeCode values 1..10 and Shared WriterSizeCode values 1..12 are accepted in every phase; Local continuation identity is carried by the final source-form binder slot, while Shared continuation reuses the final B.IOS SizeCode=0 destination and selects the exact OPEN Sx generation.
- The modifier is legal only in the contiguous immediately preceding binder group and follows source roles.

## State effects

- Store raw INIT/LAST/RegSrc/uimm11/WriterSizeCode and the derived XLEN offset in the destination carrier of the open binder group.
- PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality.

## Exceptions

- Reserved funct3/opcode and RegSrc24..31 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance; raw WriterSizeCode 13..15 is reserved and raises Fault_IllegalInstruction.
- Participating INIT, MIDDLE, and LAST writers require a legal nonzero WriterSizeCode; raw reserved codes raise Fault_IllegalInstruction.
- Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl.

## Examples

- B.IOT T0, mask=1111, ->T1<1>; B.ASSEMBLE 1, 1, a0, 0, 10
