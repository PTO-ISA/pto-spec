<!-- GENERATED FROM: asl/scalar/alu/HL.ADDIW.asl -->
# HL.ADDIW

**Normative ASL source:** `asl/scalar/alu/HL.ADDIW.asl`

HL.ADDIW applies word addition to SrcL[31:0] and the low word of a zero-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ADDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-addiw-purpose role=purpose -->
## What HL.ADDIW does

`HL.ADDIW` is the word form of the same 48-bit addition. It takes `SrcL[31:0]` and the low `32` bits of the zero-extended `uimm24`, adds them modulo `2^32`, sign-extends the `32`-bit sum to `PTO_XLEN`, and publishes the result through `RegDst`. Successful execution advances `TPC` by `6` bytes.

Design point: the word boundary belongs to the operation and not to the source register. Bits `63:32` of `SrcL` are never read, so no carry can leave bit `31`. With `a0` holding `18446744069414584320`, `hl.addiw a0, 1, ->a0` writes `1`, and the whole upper half of the source is gone from the result.

<!-- PTO-READER-BLOCK: scalar-hl-addiw-mechanism role=mechanism -->
## How the word result is formed

Decode reassembles the two 12-bit immediate pieces into one exact `uimm24` value and zero-extends it to `PTO_XLEN`. The word helper then keeps bits `31:0` of both operands, performs the addition in `32`-bit arithmetic, and sign-extends bit `31` of the sum through bit `63`.

Design point: the extension happens after the wrap, so bits `63:32` of the result are copies of result bit `31`. Every published value therefore lies in the signed range `-2147483648` through `2147483647`, whatever the source held.

`HL.ADDIW` shares its immediate field and its destination map with `HL.ADDI`. The two forms differ in how much of the source and of the result take part.

<!-- PTO-READER-BLOCK: scalar-hl-addiw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` reads one Reg5 value and only bits `31:0` of it participate: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry.
- `uimm24` supplies the unsigned addend, `0` through `16777215`.
- `RegDst` receives the sign-extended word: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: `uimm24=0` is not a no-operation for this form. `hl.addiw a0, 0, ->a0` replaces `a0` with `SrcL[31:0]` sign-extended, so an `a0` of `4294967295` becomes `18446744073709551615`. The encoded zero is a numeric addend that the word operation still extends.

<!-- PTO-READER-BLOCK: scalar-hl-addiw-effects role=effects -->
## Effects and ordering

`SrcL` is resolved before the destination is written, so `hl.addiw a0, 1, ->a0` adds to the pre-instruction `a0`. When `RegDst` is `30` or `31`, the push makes the new value `U#1` or `T#1` and discards the entry that was `U#4` or `T#4`.

Publication is followed by the `TPC` advance of `6` bytes. `HL.ADDIW` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-addiw-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and all `16777216` unsigned `24`-bit addends.

Three rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. None of them publishes a partial word.

Design point: the `32`-bit addition is total, so a carry out of bit `31` is discarded rather than reported. With the low word `4294967295`, `hl.addiw a0, 1, ->a0` produces a low word of `0` and therefore publishes `0`, with no overflow indication to read.

<!-- PTO-READER-BLOCK: scalar-hl-addiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `18446744069414584320`, `hl.addiw a0, 1, ->a0` publishes `1`, because only the low word took part. With `a0` holding `4294967295` and `uimm24=0`, `hl.addiw a0, 0, ->a0` publishes `18446744073709551615`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.addiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addiw_48_f6d7f5032964 | HL48 | 48 | 0x00000035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addiw_48_f6d7f5032964 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addiw_48_f6d7f5032964 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_addiw_48_f6d7f5032964 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addiw_48_f6d7f5032964 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_addiw_48_f6d7f5032964 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_addiw_48_f6d7f5032964 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ADDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ADDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ADDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ADDIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_ADDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ADDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ADDIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_ADD,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm24, and RegDst are required encoded fields; no field can be omitted.
- uimm24 has the complete unsigned 24-bit range 0 through 16777215; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every unsigned 24-bit value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the zero-extended uimm24, compute word addition modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ADDIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.addiw a0, 1, ->a0
- hl.addiw t#1, 16777215, ->u
- hl.addiw zero, 0, ->zero
