<!-- GENERATED FROM: asl/scalar/amo/LW.ADD.asl -->
# LW.ADD

**Normative ASL source:** `asl/scalar/amo/LW.ADD.asl`

LW.ADD atomically stores the modular 32-bit sum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LW-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-add-purpose role=purpose -->
## What LW.ADD does

`LW.ADD` adds one operand to a 4-byte memory word, writes the low 32 bits of the sum back to the same word, and publishes the word that was there before the instruction. The address comes from `SrcL`, the operand from `SrcR`, and the published value from the pre-instruction memory contents.

<!-- PTO-READER-BLOCK: scalar-lw-add-mechanism role=mechanism -->
## Adding into a 32-bit word

The form binds `ScalarHandler_AtomicReadModifyWrite` with access size `4` and atomic operation `Atomic_ADD`. A read probe and a write probe both cover the same 4 bytes; then the word is loaded, truncated to its low 32 bits, added to the low 32 bits of `SrcR`, and the 32-bit result is stored back. One atomic event is recorded with `write_performed` set to true.

Arithmetic is modular in 32 bits. A word holding `0x7fffffff` plus `SrcR = 0x0000000000000001` stores `0x80000000`; a word holding `0xffffffff` plus the same operand stores `0x0`.

Design point: the truncation happens before the addition and the carry out of bit 31 is dropped, so the upper 32 bits of `SrcR` never influence the stored word. Access size `4` also sets the alignment rule: the address must be a multiple of 4.

Design point: the published value follows a different rule from the stored bytes. `RegDst` receives the old word sign-extended to `XLEN`, so a word holding `0xffffffff` publishes `0xffffffffffffffff` while the store writes `0x0`; reading the destination as a signed 64-bit value reproduces the replaced word.

<!-- PTO-READER-BLOCK: scalar-lw-add-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`.

`SrcL` supplies the address and `SrcR` the operand; both accept every Reg5 source selector, and a selected T or U entry must be valid and is not consumed. `RegDst` takes the published value: code `0` and codes `24` to `29` discard it, code `30` pushes U, code `31` pushes T, and codes `1` to `23` write the named GPR.

Design point: `aq` and `rl` select relaxed, acquire, release, or acquire-release ordering for the atomic event, while `far` is decoded and passed to `AtomicAddress`, which returns the address unchanged, so `lw.add` and `lw.add.f` address the same word in the reference model.

<!-- PTO-READER-BLOCK: scalar-lw-add-effects role=effects -->
## Effects

A completed `LW.ADD` writes 4 bytes, records one atomic event with `write_performed` set to true, publishes the sign-extended pre-instruction word, and advances `TPC` by 4 bytes. If the written 4 bytes overlap the reserved 64-byte granule, the local reservation is cleared.

Design point: only the addressed word changes. The neighbouring 4 bytes of the same 8-byte doubleword keep their contents even when the addition carries out of bit 31, because the store width is fixed at 4 bytes.

<!-- PTO-READER-BLOCK: scalar-lw-add-constraints role=constraints -->
## Legality and faults

The address must be a multiple of 4. The read probe reports `Fault_DataAlignment` for a misaligned address and `Fault_DataPage` for an address outside the permitted region, both before the load and both at the original address; the write probe repeats the tests, and the two translated addresses must match. An undecodable form or an unavailable selected T or U source raises `Fault_IllegalInstruction` before any effect. A fault publishes nothing, leaves memory unchanged, records no atomic event, keeps the reservation, and leaves `TPC` unchanged.

Design point: the two probes complete before the load, and the reference model takes its read and write decisions from the same bounds check, so a rejected access never reaches the word and the reported fault carries the address the program supplied rather than any translated form.

<!-- PTO-READER-BLOCK: scalar-lw-add-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

With `a0` holding a 4-byte aligned address, `lw.add [a0], a1, ->a2` adds the low 32 bits of `a1` to the word at `[a0]`. If the word holds `0x7fffffff` and `a1` holds `0x0000000000000001`, the location receives `0x80000000` and `a2` receives `0x000000007fffffff`.

If the word holds `0xffffffff` and `a1` holds `0x0000000000000001`, the location receives `0x0` and `a2` receives `0xffffffffffffffff`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw.add [SrcL], SrcR, ->Rd
lw.add.aq [SrcL], SrcR, ->Rd
lw.add.rl [SrcL], SrcR, ->Rd
lw.add.f [SrcL], SrcR, ->Rd
lw.add.aqrl [SrcL], SrcR, ->Rd
lw.add.aqf [SrcL], SrcR, ->Rd
lw.add.rlf [SrcL], SrcR, ->Rd
lw.add.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_add_32_5be3ad1ad081 | L32 | 32 | 0x0000200b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_add_32_5be3ad1ad081 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_add_32_5be3ad1ad081 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_add_32_5be3ad1ad081 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_add_32_5be3ad1ad081 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lw_add_32_5be3ad1ad081 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lw_add_32_5be3ad1ad081 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_add_32_5be3ad1ad081 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| lw_add_32_5be3ad1ad081 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| lw_add_32_5be3ad1ad081 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| lw_add_32_5be3ad1ad081 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lw_add_32_5be3ad1ad081 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lw_add_32_5be3ad1ad081 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.ADD.asl -->
```asl
readonly func InstructionContractOperation_LW_ADD() => ScalarOperation
begin
    return ScalarOperation_LW_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.ADD.asl -->
```asl
readonly func InstructionContractHandler_LW_ADD() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LW_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_LW_ADD()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_LW_ADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LW_ADD()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the published old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 Reg5 destination encodings are assigned. Destination code 0 and destination codes 24..29 discard. Destination code 30 pushes U, destination code 31 pushes T, and codes 1..23 write the named absolute GPR.
- The effective address must be aligned to 4 bytes. aq, rl, and far have no reserved combinations.

## State effects

- Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.
- LW.ADD computes the modular sum at 32-bit width and publishes the prior memory value only after a successful atomic commit.
- The published old value is sign-extended from 32 bits to XLEN.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the modular 32-bit sum, and write one 4-byte result to the same location.
- On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.
- The published old value is sign-extended from 32 bits to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.
- On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- lw.add [a0], a1, ->a2
- lw.add.aqrl [t#1], u#1, ->t
- lw.add.f [sp], a0, ->u
