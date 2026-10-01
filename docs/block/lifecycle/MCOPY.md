<!-- GENERATED FROM: asl/block/lifecycle/MCOPY.asl -->
# MCOPY

**Normative ASL source:** `asl/block/lifecycle/MCOPY.asl`

Copies a non-overlapping byte range in restartable forward memory steps.

## Normative identity {#PTO-INST-BLOCK-MCOPY}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-mcopy-purpose role=purpose -->
## What MCOPY does

`MCOPY` copies a byte range from a source address to a destination address in one command. The ranges must not overlap. The copy runs forward in small steps, and each step is a restart point, so a fault part-way through keeps the bytes already copied and a retry finishes the rest.

<!-- PTO-READER-BLOCK: block-mcopy-mechanism role=mechanism -->
## Placement and execution mechanism

`MCOPY` is a standalone 32-bit command. It does not open or commit a block and does not write `BARG`.

On first execution, it reads the three GPRs and checks the ranges. It then records a copy template: the instruction PC, destination, source, length, and zero progress. Progress is the number of bytes already copied.

Each step copies the largest of 8, 4, 2, or 1 bytes that does not exceed the remaining length. A step probes the source and then the destination, and only then reads the source and writes the destination. After the last step, the command records the last memory command and advances `TPC` by 4.

Design point: both addresses of a step are probed before the source is read. The ASL comment gives the consequence: a rejected destination leaves no source read and no memory event behind.

<!-- PTO-READER-BLOCK: block-mcopy-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegSrc0`, bits `19:15`, names the GPR that holds the destination byte address.
- `RegSrc1`, bits `24:20`, names the GPR that holds the source byte address.
- `RegSrc2`, bits `31:27`, names the GPR that holds the byte count, a complete unsigned XLEN value.

Bits `14:0` are `0x0031`, and bits `26:25` are zero. Each selector accepts only the absolute GPRs `0..23`. Codes `24..31`, which name the relative T and U queue entries in other commands, are reserved here.

Design point: no operand is omitted, and encoded zero is a real register: selector 0 reads the architectural zero register. A `RegSrc2` of 0 therefore gives length zero, which is legal and copies nothing.

<!-- PTO-READER-BLOCK: block-mcopy-effects role=effects -->
## State effects and ordering

Each step records one relaxed load event and then one relaxed store event, in program order. A step whose write overlaps the local load reservation invalidates it. A successful zero-length copy performs no access and leaves the reservation unchanged.

On completion, `_LastMemoryCommandAddress` receives the original destination and `_LastMemoryCommandSize` the full length.

Design point: the template survives a fault. When the same `MCOPY` runs again at the same PC, it reuses the saved addresses and length instead of rereading the GPRs, and resumes at the first uncopied byte. Committed bytes are not copied twice.

Design point: overlap is rejected before the first step. The forward copy therefore never reads a byte that an earlier step of the same copy wrote, and the destination always receives the original source bytes.

<!-- PTO-READER-BLOCK: block-mcopy-constraints role=constraints -->
## Legality, faults, and atomicity

- A selector code in `24..31` raises `Fault_IllegalInstruction` before any register read or memory effect.
- For a nonzero length, a source or destination range that wraps past the top of the address space, or ranges that overlap, raise `Fault_IllegalInstruction` before any memory, event, reservation, progress, last-command, or `TPC` effect.
- A source or destination access fault is precise to the current step. Earlier steps stay visible; the rejected step has no read, write, event, reservation, or progress effect.
- While a copy template is active, executing `MCOPY` at a different PC raises `Fault_IllegalInstruction`.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-mcopy-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
MCOPY [a0, a1, a2]
```

Suppose `a0` holds `0x9000`, `a1` holds `0x8000`, and `a2` holds 13. The ranges `[0x9000, 0x900D)` and `[0x8000, 0x800D)` are disjoint. The command copies 8 bytes, then 4, then 1. If the 4-byte step faults on its destination, progress stays at 8 and nothing from that step is read or written. The retry copies bytes 8 to 11 and then byte 12, and records destination `0x9000` and length 13.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
MCOPY [RegSrc0, RegSrc1, RegSrc2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mcopy_32_4fc4a803e995 | L32 | 32 | 0x00000031 / 0x06007fff | [{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mcopy_32_4fc4a803e995 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mcopy_32_4fc4a803e995 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| mcopy_32_4fc4a803e995 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mcopy_32_4fc4a803e995 | RegSrc0 | 5 | 0–23 | none | 24–31 | absolute GPR containing destination byte address | Encoded zero reads destination byte address zero. |
| mcopy_32_4fc4a803e995 | RegSrc1 | 5 | 0–23 | none | 24–31 | absolute GPR containing source byte address | Encoded zero reads source byte address zero. |
| mcopy_32_4fc4a803e995 | RegSrc2 | 5 | 0–23 | none | 24–31 | absolute GPR containing complete unsigned XLEN byte count | Encoded zero reads length zero and selects the legal memory-free no-op. |

- `mcopy_32_4fc4a803e995.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mcopy_32_4fc4a803e995.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mcopy_32_4fc4a803e995.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | absolute GPR containing destination byte address |
| RegSrc1 | absolute GPR containing source byte address |
| RegSrc2 | absolute GPR containing complete unsigned XLEN byte count |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractMatches_MCOPY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mcopy_32_4fc4a803e995);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
MCOPY is one standalone template block. It retires only after the complete byte range has copied or after a legal zero-length no-op.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractHandler_MCOPY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemoryCopy;
end;

pure func InstructionContractMemoryStepRestartable_MCOPY()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractForbidsOverlap_MCOPY()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No operand is omitted. RegSrc0, RegSrc1, and RegSrc2 are absolute GPR selectors 0..23; selector zero reads architectural zero.
- RegSrc2 supplies the complete unsigned XLEN byte count. Zero length is legal and performs no memory access.

## Legality

- Each RegSrc field accepts exactly absolute GPR selectors 0..23. Relative T/U selector codes 24..31 are reserved for MCOPY.
- For nonzero length, both half-open intervals must be non-wrapping and disjoint.

## State effects

- At accepted start, snapshot destination, source, length, instruction PC, and zero progress into trap-preserved MemoryCopyTemplateState.
- After the final step, clear active progress, record the original destination and full length as the last memory command, and retire exactly once.

## Memory effects and ordering

### Memory effects

- Copy forward from source to destination in 8-, 4-, 2-, or 1-byte steps. Each step probes source and destination before reading, then records the source load and destination store in program order.
- The step write invalidates an overlapping local reservation. A successful zero-length command performs no access and does not change reservation state.

### Ordering

- Each source read precedes its corresponding destination write. The write and progress advance commit together at one restart boundary.
- On recovery the template resumes from its saved operand snapshot and first uncommitted byte without rereading GPRs or repeating earlier memory events.

## Exceptions

- Selector codes 24..31, a wrapping source or destination interval, or overlapping nonempty intervals raise Fault_IllegalInstruction before register-dependent memory, event, reservation, progress, last-command, or TPC effects.
- A source or destination access fault is precise to the current memory step. Earlier completed steps remain visible; the rejected step has no read, write, event, reservation, or progress effect.

## Examples

- MCOPY [a0, a1, a2]
