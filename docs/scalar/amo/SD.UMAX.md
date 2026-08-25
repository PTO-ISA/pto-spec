<!-- GENERATED FROM: asl/scalar/amo/SD.UMAX.asl -->
# SD.UMAX

**Normative ASL source:** `asl/scalar/amo/SD.UMAX.asl`

SD.UMAX atomically replaces the aligned 64-bit memory value with its unsigned maximum with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SD-UMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-umax-purpose role=purpose -->
## What SD.UMAX does

`SD.UMAX` atomically applies unsigned maximum to one doubleword and stores the result without publishing the old value.

<!-- PTO-READER-BLOCK: scalar-sd-umax-mechanism role=mechanism -->
## Atomic mechanism

The ASL DOC contract selects `ScalarHandler_AtomicReadModifyWrite` with an access width of `8` bytes.

Read and write access are preflighted before the same-location atomic read-modify-write is allowed to commit.

<!-- PTO-READER-BLOCK: scalar-sd-umax-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 atomic address source; `SrcR` carries the Reg5 atomic operand source; `far` carries the flat-address routing hint; `rl` carries the release ordering bit.

`rl` selects relaxed or release ordering; this form has no acquire bit; `far` is a profile routing hint and does not change the architectural result in the reference profile.

<!-- PTO-READER-BLOCK: scalar-sd-umax-effects role=effects -->
## Effects and ordering

This store-only form has no destination field; successful commit updates memory and emits one atomic event.

A completed write invalidates an overlapping local 64-byte-line reservation, preserves a nonoverlapping reservation, and advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-sd-umax-constraints role=constraints -->
## Legality and precise faults

The effective address must be aligned to `8` bytes. Alignment, translation, and permission checks precede architectural effects.

A failing preflight publishes no destination, memory event, reservation update, or retirement effect; the saved original `TPC` supports full reissue.

<!-- PTO-READER-BLOCK: scalar-sd-umax-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

For a first reading, use `sd.umax [SrcL], SrcR` and then vary only the ordering or route modifiers described above.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.umax [SrcL], SrcR
sd.umax.rl [SrcL], SrcR
sd.umax.f [SrcL], SrcR
sd.umax.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_umax_32_89c5ec42be68 | L32 | 32 | 0x6000500b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_umax_32_89c5ec42be68 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_umax_32_89c5ec42be68 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_umax_32_89c5ec42be68 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sd_umax_32_89c5ec42be68 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_umax_32_89c5ec42be68 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sd_umax_32_89c5ec42be68 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sd_umax_32_89c5ec42be68 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sd_umax_32_89c5ec42be68 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.UMAX.asl -->
```asl
readonly func InstructionContractOperation_SD_UMAX() => ScalarOperation
begin
    return ScalarOperation_SD_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.UMAX.asl -->
```asl
readonly func InstructionContractHandler_SD_UMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SD_UMAX()
    => AtomicOperation
begin
    return Atomic_UMAX;
end;

pure func InstructionContractAtomicSizeBytes_SD_UMAX()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_SD_UMAX()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.
- rl=0 selects relaxed ordering; rl=1 selects release ordering.
- far=0 selects the default flat-address route. far=1 is a routing hint and does not change the architectural address or atomic operation in the reference profile.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- The effective address must be aligned to 8 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SD.UMAX compares both values as unsigned integers and selects the larger value at 64-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the unsigned maximum, and write one 8-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sd.umax [a0], a1
- sd.umax.rl [t#1], u#1
- sd.umax.f [sp], a0
