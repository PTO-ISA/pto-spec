<!-- GENERATED FROM: asl/scalar/alu/MULW.asl -->
# MULW

**Normative ASL source:** `asl/scalar/alu/MULW.asl`

MULW multiplies the source low 32-bit values, retains the low 32 product bits, sign-extends them to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MULW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-mulw-purpose role=purpose -->
## What MULW does

`MULW` multiplies the low `32` bits of two Reg5 sources as unsigned bit patterns, keeps the low `32` bits of the `64`-bit product, sign-extends bit `31` of that word to `PTO_XLEN`, and publishes one word.

The instruction has three fields and no immediate: `RegDst` at instruction slice `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`. The `32`-bit carrier matches `0x00002047` under mask `0xfe00707f`.

The companion mnemonic `MULUW` reaches the same helper, so `MULW` and `MULUW` publish bit-identical results for the same source bits.

<!-- PTO-READER-BLOCK: scalar-mulw-mechanism role=mechanism -->
## How the product is formed

The owning ASL routes the operation to `ScalarMultiplyW(left, right)`. That helper zero-extends `left[31:0]` and `right[31:0]` to `PTO_XLEN`, calls `MultiplyWord` on the two extended values, and returns `SignExtend{PTO_XLEN}(product[31:0])`. Dispatch calls it for `ScalarOperation_MULW` and `ScalarOperation_MULUW` at `asl/scalar/model/dispatch/alu.asl:265-270`.

```asm
mulw SrcL, SrcR, ->{t, u, Rd}
```

Design point: The zero extension is only a vehicle for the multiplication: it makes the low word a non-negative `64`-bit value. The extension that a reader actually sees is the final sign extension, so a low word of `0x80000000` is published as `0xFFFFFFFF80000000`.

Design point: Because the product is truncated to `32` bits before anything else, the helper carries no wide result. `mulw` can never publish more than the low word of the product, however large the operands are.

Signedness of the sources is irrelevant to the helper. Only `left[31:0]` and `right[31:0]` reach `MultiplyWord`, so two registers that agree in their low words give the same answer whatever their upper halves hold.

<!-- PTO-READER-BLOCK: scalar-mulw-inputs role=inputs-outputs -->
## Inputs and destination

Both operands come from the shared Reg5 source map, and the single result leaves through the shared Reg5 destination map.

- `SrcL` at `[15 +: 5]` is the left multiplicand: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and no read consumes a queue entry.
- `SrcR` at `[20 +: 5]` is the right multiplicand and uses the same five-bit map.
- `RegDst` at `[7 +: 5]` publishes the sign-extended word: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard the result.
- Encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, so `mulw` with a zero source and any destination publishes `0`.

Design point: Discarding is an encoded choice, not an absence: `RegDst=0` still runs the multiplication and still advances `TPC`. A program that only wants the fault behaviour of the instruction can encode a discard destination.

<!-- PTO-READER-BLOCK: scalar-mulw-effects role=effects -->
## Effects and ordering

The two sources are read before `RegDst` is written, so a destination that aliases a source still multiplies the pre-instruction values. The published word is the only architectural change apart from one queue push when `RegDst` is `30` or `31`.

A successful `MULW` then advances `TPC` by `4` bytes, the length of the `32`-bit carrier. `MULW` reads no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged.

Design point: `MULW` records no numeric status. A truncated product leaves no sticky flag behind, so a later instruction cannot observe that an overflow was discarded.

<!-- PTO-READER-BLOCK: scalar-mulw-constraints role=constraints -->
## Legality and fault boundary

All `32` source codes and all `32` destination codes are assigned, and the form carries no constraint entry beyond its fixed encoding bits.

An unmatched `32`-bit carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; for an ALU operation that happens only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`.

Every one of those checks precedes the destination effect and the `TPC` advance.

Design point: The arithmetic itself is total. Neither the multiplication nor the truncation nor the sign extension can fault, so the whole fault boundary of `MULW` is encoding validity and source availability; no operand value selects a trap.

<!-- PTO-READER-BLOCK: scalar-mulw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `6` and `a1` holding `7`, `mulw a0, a1, ->a2` writes `42` to `a2`: the low word of the product is `42` and the sign extension leaves it unchanged.

With `a0` holding `0x80000000` and `a1` holding `2`, the low word of the product is `0x00000000` because bit `32` of the product falls outside the kept `32` bits; `a2` therefore receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
mulw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mulw_32_b90cb6a30a23 | L32 | 32 | 0x00002047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mulw_32_b90cb6a30a23 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mulw_32_b90cb6a30a23 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mulw_32_b90cb6a30a23 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mulw_32_b90cb6a30a23 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| mulw_32_b90cb6a30a23 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| mulw_32_b90cb6a30a23 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULW.asl -->
```asl
readonly func InstructionContractOperation_MULW() => ScalarOperation
begin
    return ScalarOperation_MULW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULW.asl -->
```asl
readonly func InstructionContractHandler_MULW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
pure func InstructionContractResult_MULW(left: Word, right: Word) => Word
begin
    return ScalarMultiplyW(left, right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Multiply the source low 32-bit patterns modulo 2^32, then sign-extend result bit 31 through XLEN.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- mulw srcl, srcr, ->{t, u, rd}
