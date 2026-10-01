<!-- GENERATED FROM: asl/scalar/amo/LW.UMAX.asl -->
# LW.UMAX

**Normative ASL source:** `asl/scalar/amo/LW.UMAX.asl`

LW.UMAX atomically stores the width-sized unsigned maximum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LW-UMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-umax-purpose role=purpose -->
## What LW.UMAX does
`LW.UMAX` atomically updates one aligned 4-byte memory value and also publishes the value that was replaced. The summary recorded for this form is: LW.UMAX atomically stores the width-sized unsigned maximum and publishes the prior memory value.
The `LW` prefix marks the width, 4 bytes of memory per operation. The prior value is published through the Reg5 destination named by `RegDst`, which may be a GPR or a temporary queue.

<!-- PTO-READER-BLOCK: scalar-lw-umax-mechanism role=mechanism -->
## Atomic mechanism
The instruction contract selects `ScalarHandler_AtomicReadModifyWrite` at width `4` and maps this operation to `Atomic_UMAX`. Scalar dispatch calls `AtomicReadModifyWrite`, which preflights the same address twice, reads, combines, and writes back, and returns the prior memory value.
`Atomic_UMAX` compares `UInt(old_value)` with `UInt(operand)` and returns the larger.
Here the dispatch passes `write_result` as `TRUE`, so the helper return value passes through `NormalizeAtomicReturn` into `RegDst`. At size `4` that helper sign-extends the low 32 bits to `PTO_XLEN`.
Design point: both sources are read before the destination is written. `RegDst` may name `SrcL` itself, so the old value can overwrite the register that supplied the address, but the address and operand are already captured and the atomic commit is unaffected.

<!-- PTO-READER-BLOCK: scalar-lw-umax-inputs-outputs role=inputs-outputs -->
## Inputs and result
`SrcL` is the Reg5 source that supplies the atomic address. `SrcR` supplies the atomic operand, an old value is read from that address, and the stored value comes from the value already at the address, compared as unsigned integers with the larger value kept. `RegDst` is the Reg5 destination that receives the prior memory value.
`aq` is the acquire bit and `rl` the release bit: together they select relaxed, acquire, release, or acquire-release ordering for the atomic event. `far` is a route hint only: `AtomicAddress` returns its `address` argument unchanged, so `far` does not change the architectural address, the ordering, or the result.
All 32 Reg5 destination codes are assigned and all are legal: `0` and `24`..`29` discard the published value, `30` pushes the `U` queue, `31` pushes the `T` queue, and `1`..`23` write the named absolute GPR. Source codes `0`..`23` name GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`.

<!-- PTO-READER-BLOCK: scalar-lw-umax-effects role=effects -->
## Effects, publication, and ordering
A successful operation reads the old value, computes the unsigned maximum, writes the result back, records one atomic memory event, and publishes the sign-extended old value through `RegDst` after the atomic commit. The helper returns the old value unchanged; the caller applies the sign extension.
The completed write invalidates a local reservation that overlaps the written range, and leaves a nonoverlapping one untouched; the check happens inside `StoreTranslated` against the 64-byte reservation granule. Success then advances `TPC` by `4` bytes.
Design point: the same 4 bytes are handled differently. The store writes the raw 32-bit result, while the published value is sign-extended to `PTO_XLEN`, so a caller that wants the untouched 32-bit pattern must read the low half of the published value.

<!-- PTO-READER-BLOCK: scalar-lw-umax-constraints role=constraints -->
## Legality and precise faults
The effective address must be aligned to `4` bytes. `ProbeDataAccess` compares the address against the access width before it consults translation, so misalignment is reported ahead of a translation or permission fault, and a failing probe reports the original architectural address.
On any fault the instruction publishes no destination and performs no load, store, memory event, reservation update, or `TPC` advance. One further outcome exists when both probes pass but resolve to different translated addresses: the helper sets `Fault_DataPage` on the original address and changes no memory.
`Fault_IllegalInstruction` is raised before any effect when no form decodes the 32-bit pattern (this one matches `0x6000200b` under mask `0xf000707f`), and also when a named source selects a temporary queue entry that is not currently valid. Encoded zero in `SrcL` reads the architectural zero register as the address, and encoded zero in `SrcR` supplies numeric zero as the operand.
Design point: the destination is written only when the whole operation succeeded, so a trap can never leave a caller holding an old value that the failed attempt did not actually replace.

<!-- PTO-READER-BLOCK: scalar-lw-umax-example role=example -->
## Non-normative example
This example illustrates the current ASL owner and does not replace the normative operation.
The eight accepted spellings combine the optional `.aq`, `.rl`, and `.f` suffixes; the destination may also be written `->t` or `->u`.
```text
lw.umax [SrcL], SrcR, ->Rd
lw.umax.aq [SrcL], SrcR, ->Rd
lw.umax.rl [SrcL], SrcR, ->Rd
lw.umax.f [SrcL], SrcR, ->Rd
lw.umax.aqrl [SrcL], SrcR, ->Rd
lw.umax.aqf [SrcL], SrcR, ->Rd
lw.umax.rlf [SrcL], SrcR, ->Rd
lw.umax.aqrlf [SrcL], SrcR, ->Rd
```
The low 32 bits read from memory are `0xffffffff`; the register named by `SrcR` holds `1`.
Read as unsigned integers the memory value is larger, so `0xffffffff` is stored.
The published value is the prior `0xffffffff` sign-extended to `0xffffffffffffffff`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw.umax [SrcL], SrcR, ->Rd
lw.umax.aq [SrcL], SrcR, ->Rd
lw.umax.rl [SrcL], SrcR, ->Rd
lw.umax.f [SrcL], SrcR, ->Rd
lw.umax.aqrl [SrcL], SrcR, ->Rd
lw.umax.aqf [SrcL], SrcR, ->Rd
lw.umax.rlf [SrcL], SrcR, ->Rd
lw.umax.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_umax_32_3c6a5a534674 | L32 | 32 | 0x6000200b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_umax_32_3c6a5a534674 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_umax_32_3c6a5a534674 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_umax_32_3c6a5a534674 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_umax_32_3c6a5a534674 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lw_umax_32_3c6a5a534674 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lw_umax_32_3c6a5a534674 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_umax_32_3c6a5a534674 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| lw_umax_32_3c6a5a534674 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| lw_umax_32_3c6a5a534674 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| lw_umax_32_3c6a5a534674 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lw_umax_32_3c6a5a534674 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lw_umax_32_3c6a5a534674 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.UMAX.asl -->
```asl
readonly func InstructionContractOperation_LW_UMAX() => ScalarOperation
begin
    return ScalarOperation_LW_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.UMAX.asl -->
```asl
readonly func InstructionContractHandler_LW_UMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LW_UMAX()
    => AtomicOperation
begin
    return Atomic_UMAX;
end;

pure func InstructionContractAtomicSizeBytes_LW_UMAX()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_LW_UMAX()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LW_UMAX()
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
- LW.UMAX computes the unsigned maximum at 32-bit width and publishes the prior memory value only after a successful atomic commit.
- The published old value is sign-extended from 32 bits to XLEN.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the width-sized unsigned maximum, and write one 4-byte result to the same location.
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

- lw.umax [a0], a1, ->a2
- lw.umax.aqrl [t#1], u#1, ->t
- lw.umax.f [sp], a0, ->u
