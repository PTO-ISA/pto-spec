<!-- GENERATED FROM: asl/scalar/alu/XORIW.asl -->
# XORIW

**Normative ASL source:** `asl/scalar/alu/XORIW.asl`

XORIW performs word exclusive-or with a signed 12-bit immediate and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-XORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xoriw-purpose role=purpose -->
## What XORIW computes

`XORIW` is the word form of the immediate exclusive OR. It combines only the low 32 bits of `SrcL` with the low 32 bits of the sign-extended immediate, sign-extends that 32-bit result to `PTO_XLEN`, and publishes it through `RegDst`.

The word rule is what separates `XORIW` from `XORI`: the operation is 32 bits wide, and bit 31 of the result decides all 32 upper bits of the published value. `XORIW` is a 32-bit form that advances `TPC` by `4` bytes, reads no memory and raises no arithmetic exception.

Design point: because the result is sign-extended rather than zero-extended, `XORIW` can publish a negative XLEN value from two small positive operands. With `SrcL=0x0000000000000000` and `simm=-1` it publishes `0xffffffffffffffff`, never `0x00000000ffffffff`.

<!-- PTO-READER-BLOCK: scalar-xoriw-mechanism role=mechanism -->
## The 32-bit window

Execution sign-extends the signed `simm12` field from `-2048` through `2047` to 64 bits, takes the low 32 bits of that value and the low 32 bits of `SrcL`, exclusive-ORs those two words, then sign-extends the 32-bit result to 64 bits.

Design point: only bits `31..0` of `SrcL` take part. With `SrcL=0xffffffff00000000` and `simm=0` the published value is `0x0`, while the 64-bit form `XORI` with the same operands publishes `0xffffffff00000000`. The two mnemonics are therefore not interchangeable when the high half of the source matters.

Design point: the immediate is sign-extended before the narrowing, so its low 32 bits are what enter the operation. `-1` becomes `0xffffffff` inside that window and complements the low word of the source, while its upper all-ones bits are discarded rather than folded into the result.

<!-- PTO-READER-BLOCK: scalar-xoriw-inputs role=inputs-outputs -->
## Encoded operands

- `RegDst` is a 5-bit field at instruction bits `7..11`: codes `1..23` write that absolute GPR, code `0` and codes `24..29` discard, code `30` pushes the U queue and code `31` pushes the T queue.
- `SrcL` is a 5-bit field at bits `15..19`, but only its low 32 bits reach the operation: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4` and `28..31` read `U#1..U#4`.
- `simm12` is a signed 12-bit field at bits `20..31`.

Source code `0` reads zero and a T/U source is read without consuming the queue entry. The encoding has no `SrcRType` and no `shamt`, so the right operand is always the immediate and it is never shifted.

<!-- PTO-READER-BLOCK: scalar-xoriw-effects role=effects -->
## Destination and ordering

`SrcL` is read before the destination is written, and the published value is computed from that pre-instruction value.

Design point: `SrcL` is read before the destination is written, so `xoriw a0, -1, ->a0` complements the low word of the old `a0` and sign-extends it; the freshly written value never feeds the operation.

`XORIW` advances `TPC` by `4` bytes after a successful execution. No memory location, reservation, descriptor, numeric flag, trap, block, privilege or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-xoriw-constraints role=constraints -->
## Legality and the fault boundary

Every `SrcL` and `RegDst` code and every signed 12-bit immediate is assigned, so `XORIW` has no reserved field value. Word exclusive OR and the final sign extension are defined for every source and immediate bit pattern, so no arithmetic exception is raised.

Before any effect the form is decoded, its encoded fields are checked, and a selected T/U source must hold a valid queue entry. A pattern owned by no form, or an unavailable `T#1..T#4` or `U#1..U#4` entry, raises `Fault_IllegalInstruction` before the destination is written and before `TPC` advances.

Design point: the 32-bit width is a property of the operation, so an operand or result value that does not fit in 32 bits is truncated rather than rejected. There is no overflow fault and no legality rule that inspects the source value.

<!-- PTO-READER-BLOCK: scalar-xoriw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=0x0000000012345678` and `simm=-1`, the two 32-bit values inside the window are `0x12345678` and `0xffffffff`. Their exclusive OR is `0xedcba987`, and the published value is the sign-extended `0xffffffffedcba987`.

A second case shows the narrow window: `SrcL=0xffffffff00000000` with `simm=0` publishes `0x0`, because the upper 32 bits of the source do not participate.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xoriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xoriw_32_1f8c6f43e2bd | L32 | 32 | 0x00004035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xoriw_32_1f8c6f43e2bd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xoriw_32_1f8c6f43e2bd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xoriw_32_1f8c6f43e2bd | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xoriw_32_1f8c6f43e2bd | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| xoriw_32_1f8c6f43e2bd | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| xoriw_32_1f8c6f43e2bd | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORIW.asl -->
```asl
readonly func InstructionContractOperation_XORIW()
    => ScalarOperation
begin
    return ScalarOperation_XORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORIW.asl -->
```asl
readonly func InstructionContractHandler_XORIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_XORIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_XORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XORIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal. Only the low 32 bits of SrcL and the sign-extended immediate participate.

## State effects

- Sign-extend simm12, XOR its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- XORIW raises no arithmetic exception; word exclusive-or and final sign extension are defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xoriw a0, -1, ->a0
- xoriw u#1, 2047, ->t
- xoriw zero, -2048, ->zero
