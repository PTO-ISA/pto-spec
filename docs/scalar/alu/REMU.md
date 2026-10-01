<!-- GENERATED FROM: asl/scalar/alu/REMU.asl -->
# REMU

**Normative ASL source:** `asl/scalar/alu/REMU.asl`

REMU computes the unsigned XLEN remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remu-purpose role=purpose -->
## What REMU does

`REMU` treats both complete `PTO_XLEN` sources as unsigned integers and publishes the unsigned remainder. It has three five-bit fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00005057` under mask `0xfe00707f`. The mnemonic carries no encoded mode, so the operand interpretation is exactly the unsigned one.

Because the values are unsigned, the plain pattern comparison of a source decides whether it is larger than the divisor; no sign bit is special.

<!-- PTO-READER-BLOCK: scalar-remu-mechanism role=mechanism -->
## How the remainder is formed

Dispatch calls `ScalarRemainderUnsigned(left, right)` with both sources read through the Reg5 map (`asl/scalar/model/dispatch/alu.asl:240-245`). A zero divisor returns the dividend unchanged; otherwise `DivideWordUnsigned` performs restoring division over `PTO_XLEN` steps and the helper returns `dividend - quotient * divisor`.

```asm
remu SrcL, SrcR, ->{t, u, Rd}
```

Design point: The restoring-division comparison is on `UInt` values, so a dividend with bit `63` set is treated as a value above `2^63`, not as a negative number. `remu` with dividend `0xFFFFFFFFFFFFFFFF` and divisor `2` publishes `1`, whereas `rem` publishes `-1` for the same bit patterns.

Design point: `DivideWordUnsigned` subtracts the divisor whenever the running remainder reaches it, so a nonzero divisor always leaves a remainder smaller than the divisor and never negative. There is no sign correction step after the loop, and the published word is the raw pattern of `dividend - quotient * divisor`.

<!-- PTO-READER-BLOCK: scalar-remu-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the dividend, `SrcR` the divisor, and `RegDst` the destination of the remainder.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and no read consumes an entry.
- `SrcR`, instruction slice `[20 +: 5]`: same five-bit map; the divisor is used only to compare and subtract.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR and selects the defined zero-divisor answer, which is the unchanged dividend.

Design point: The zero-divisor answer is the dividend itself, which can be as large as the full `PTO_XLEN` pattern. A program that relies on a remainder smaller than the divisor must therefore exclude the zero divisor first.

<!-- PTO-READER-BLOCK: scalar-remu-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination write, so a destination aliasing `SrcL` or `SrcR` divides the pre-instruction values. The remainder is published and `TPC` advances by `4` bytes.

No memory is accessed, and reservation, descriptor, numeric-flag, trap, bundle, privilege, branch-target and control-flow state stay unchanged. A `30` or `31` destination is the only case in which a temporary queue moves.

Design point: The instruction writes exactly one architectural value. The quotient that the restoring loop computed is a helper-local binding, so no consumer can read it without running `DIVU`.

<!-- PTO-READER-BLOCK: scalar-remu-constraints role=constraints -->
## Legality and fault boundary

Every source code and every destination code of the `32`-value Reg5 domain is assigned, and the form has no constraint entry beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `REMU` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. All checks precede the destination effect and the `TPC` advance.

Design point: Unsigned division is total over the whole operand domain, including a zero divisor, so `REMU` has no operand-selected trap. Its fault boundary is encoding validity and source availability.

<!-- PTO-READER-BLOCK: scalar-remu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `10` and `a1` holding `4`, `remu a0, a1, ->a2` publishes `2`.

With `a0` holding `0xFFFFFFFFFFFFFFFF` and `a1` holding `2`, the unsigned remainder is `1`, so `a2` receives `1`. Setting `a1` to `0` publishes the whole dividend `0xFFFFFFFFFFFFFFFF`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remu_32_d7a5d1ebbbf5 | L32 | 32 | 0x00005057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remu_32_d7a5d1ebbbf5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remu_32_d7a5d1ebbbf5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remu_32_d7a5d1ebbbf5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remu_32_d7a5d1ebbbf5 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remu_32_d7a5d1ebbbf5 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remu_32_d7a5d1ebbbf5 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractOperation_REMU() => ScalarOperation
begin
    return ScalarOperation_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractHandler_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsigned;
end;
pure func InstructionContractResult_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsigned(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret both complete XLEN sources as unsigned integers and return the unsigned remainder.
- A zero divisor returns the unchanged dividend.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- remu a0, a1, ->a2
- remu t#1, zero, ->u
