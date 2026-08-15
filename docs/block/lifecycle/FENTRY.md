<!-- GENERATED FROM: asl/block/lifecycle/FENTRY.asl -->
# FENTRY

**Normative ASL source:** `asl/block/lifecycle/FENTRY.asl`

Creates a restartable stack frame by snapshotting and storing one inclusive callee-save register-ring range.

## Normative identity {#PTO-INST-BLOCK-FENTRY}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | L32 | 32 | 0x00000041 / 0x0000707f | [{"field":"SrcBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SrcEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | uimm | 15 | 0–32767 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fentry_32_a47584ec13b6.SrcBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fentry_32_a47584ec13b6.SrcEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcBegin | first register in the inclusive R2..R23 ring range |
| SrcEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractMatches_FENTRY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fentry_32_a47584ec13b6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractHandler_FENTRY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameEntry;
end;

func ExecuteFENTRY(begin_reg: Reg5Selector,
                   end_reg: Reg5Selector,
                   frame_size: Word)
begin
    EnterFrame(begin_reg, end_reg, frame_size);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and represents a byte count in multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The source range is snapshotted before sp changes, so a range containing sp stores the caller sp.

## Legality

- SrcBegin and SrcEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- The accepted start records instruction PC, endpoints, count, frame size, caller sp, complete source snapshot, and zero progress.
- After the final store, increment frame depth, publish the last-frame tuple, clear active progress, and retire once.

## Memory effects and ordering

### Memory effects

- Store one aligned eight-byte snapshot per selected register into consecutive descending slots below the caller sp.
- Every store records one relaxed store event and follows the ordinary PTO precise data-access fault contract.

### Ordering

- Snapshot the complete source range, subtract uimm from sp, then store snapshots in range order to caller_sp-8, caller_sp-16, and subsequent descending slots.
- Each store and progress advance commit atomically; recovery never rereads source registers or repeats an earlier store.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.

## Examples

- FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
