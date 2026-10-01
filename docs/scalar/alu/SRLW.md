<!-- GENERATED FROM: asl/scalar/alu/SRLW.asl -->
# SRLW

**Normative ASL source:** `asl/scalar/alu/SRLW.asl`

SRLW performs a logical right shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SRLW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srlw-purpose role=purpose -->
## What SRLW does

`SRLW` shifts the low `32` bits of `SrcL` logically right by an amount taken from the low five bits of `SrcR` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00005025` under mask `0xfe00707f`.

The count source can be computed at run time, while the value being shifted is truncated to its low word.

<!-- PTO-READER-BLOCK: scalar-srlw-mechanism role=mechanism -->
## How the word shift is formed

Dispatch reaches `ScalarBinaryW(ScalarBinary_SRL, left, right)` through `ExecuteDecodedSimpleBinary` with `word_operation` true (`asl/scalar/model/dispatch/alu.asl:182-183`). The helper binds `left32` to `left[31:0]`, shifts with `LSR(left32, UInt(right[4:0]))`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:482`).

```asm
srlw SrcL, SrcR, ->{t, u, Rd}
```

Design point: The count comes from the full `SrcR`, so a count value with bits above bit `4` set still supplies its low five bits. A count register holding `5` shifts by `5`, and a count register holding `37` also shifts by `5`.

Design point: The final sign extension means the published word is a signed value even though the shift is logical. A program that wants an unsigned word result treats the low `32` bits of the destination as the answer and ignores the upper half.

<!-- PTO-READER-BLOCK: scalar-srlw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the shifted value, `SrcR` the count source, and `RegDst` the destination.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `SrcR`, instruction slice `[20 +: 5]`: count source, same map; every value is legal and only bits `4:0` are used.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which supplies amount `0`.

Design point: A count whose low five bits are `0` publishes the sign extension of the source word, which need not be the same as the source register. With `a0 = 0x00000000FFFFFFFF`, `srlw a0, a1, ->a2` with `a1 = 0` publishes `0xFFFFFFFFFFFFFFFF`, because the word is `-1` as a signed value.

<!-- PTO-READER-BLOCK: scalar-srlw-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination write, so a destination aliasing either source shifts pre-instruction values. The sign-extended word is published and `TPC` advances by `4` bytes.

`SRLW` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; a `30` or `31` destination is the only case in which a temporary queue moves.

Design point: The instruction has one destination and records no status. The low word of the destination holds the shifted pattern and the upper half repeats its bit `31`, so the raw shifted word is always recoverable from the published value.

<!-- PTO-READER-BLOCK: scalar-srlw-constraints role=constraints -->
## Legality and fault boundary

Every Reg5 source code and every Reg5 destination code is assigned, and the form carries no constraint entry beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRLW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: Both the count truncation and the value truncation are total, so `SRLW` has no operand-selected trap. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-srlw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `16` and `a1` holding `2`, `srlw a0, a1, ->a2` publishes `4`.

With `a0` holding `0x0000000080000000` and `a1` holding `31`, the word result is `1` and `a2` receives `1`. With `a1` holding `32`, the low five bits of the count are `0`, so the result word is `0x80000000` and `a2` receives `0xFFFFFFFF80000000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srlw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srlw_32_2c6458b2aadb | L32 | 32 | 0x00005025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srlw_32_2c6458b2aadb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srlw_32_2c6458b2aadb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srlw_32_2c6458b2aadb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srlw_32_2c6458b2aadb | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srlw_32_2c6458b2aadb | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| srlw_32_2c6458b2aadb | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractOperation_SRLW()
    => ScalarOperation
begin
    return ScalarOperation_SRLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractHandler_SRLW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SRLW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SRLW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRLW(right);
    let shifted = LSR(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SRLW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low five bits of the snapshotted SrcR select the shift amount 0 through 31; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low five bits contribute to the shift amount.

## State effects

- Compute the logical right shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRLW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- srlw a0, a1, ->a2
- srlw t#1, u#1, ->u
- srlw zero, zero, ->zero
