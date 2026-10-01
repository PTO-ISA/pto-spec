<!-- GENERATED FROM: asl/scalar/alu/HL.ANDIW.asl -->
# HL.ANDIW

**Normative ASL source:** `asl/scalar/alu/HL.ANDIW.asl`

HL.ANDIW applies word bitwise conjunction to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ANDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-andiw-purpose role=purpose -->
## What HL.ANDIW does

`HL.ANDIW` is the word form of the conjunction. It sign-extends `simm24` to `PTO_XLEN`, keeps the low `32` bits of that mask, combines them bitwise with `SrcL[31:0]`, sign-extends bit `31` of the `32`-bit result to `PTO_XLEN`, and publishes it through `RegDst`. Successful execution advances `TPC` by `6` bytes.

Design point: `hl.andiw a0, -1, ->a0` does not leave `a0` alone the way `hl.andi a0, -1, ->a0` does. The word mask is all ones, so the low word survives, but the `32`-bit result is then sign-extended: a source of `4294967295` is republished as `18446744073709551615`.

<!-- PTO-READER-BLOCK: scalar-hl-andiw-mechanism role=mechanism -->
## How the word mask is formed

Decode rebuilds one exact `24`-bit value from the two 12-bit pieces and sign-extends it. Bits `23:0` of the mask are the encoded value and bits `31:24` are its sign bit, so a negative `simm24` sets all eight of them and a non-negative one clears all eight. The conjunction is then bitwise over the `32` mask bits.

Design point: a non-negative `simm24` therefore clears source bits `31:24` as well as every bit above bit `23`. `hl.andiw a0, 8388607, ->a0` keeps `SrcL[22:0]`, and because result bit `31` is then `0`, bits `63:32` of the published value are all zero.

<!-- PTO-READER-BLOCK: scalar-hl-andiw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` reads one Reg5 value and only bits `31:0` participate: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and a relative read does not consume the entry.
- `simm24` supplies the signed mask, `-8388608` through `8388607`.
- `RegDst` receives the sign-extended word: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: `simm24=0` supplies a mask of zero for all `32` word bits, so `hl.andiw a0, 0, ->a0` publishes `0`. The mask that keeps the low word exactly as it stands is `-1`, and even that one still rewrites the bits above bit `31`.

<!-- PTO-READER-BLOCK: scalar-hl-andiw-effects role=effects -->
## Effects and ordering

`SrcL` is resolved before publication, so the destination may name the source register and still read the pre-instruction value. The source queue is read and not popped; a `T` or `U` destination push makes the new value index `1` of that queue and discards whatever was at index `4`.

Publication is followed by the `TPC` advance of `6` bytes. `HL.ANDIW` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-andiw-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every signed `24`-bit mask from `-8388608` through `8388607`.

Three rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Each precedes the destination effect and the `TPC` advance.

Design point: the `32`-bit conjunction is total. It cannot overflow and cannot raise an arithmetic exception, so the only mechanism on this page that sets or clears bits above bit `31` is the sign extension of the result.

<!-- PTO-READER-BLOCK: scalar-hl-andiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `4294967295` and `simm24=-1`, `hl.andiw a0, -1, ->a0` publishes `18446744073709551615`. With the same source and `simm24=8388607`, it publishes `8388607`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.andiw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_andiw_48_878c6594c6ff | HL48 | 48 | 0x00002035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_andiw_48_878c6594c6ff | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_andiw_48_878c6594c6ff | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_andiw_48_878c6594c6ff | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_andiw_48_878c6594c6ff | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_andiw_48_878c6594c6ff | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_andiw_48_878c6594c6ff | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ANDIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ANDIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_AND,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm24, and RegDst are required encoded fields; no field can be omitted.
- simm24 has the complete signed 24-bit range -8388608 through 8388607; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every signed 24-bit two's-complement value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise conjunction modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ANDIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.andiw a0, -1, ->a0
- hl.andiw t#1, -8388608, ->u
- hl.andiw zero, 8388607, ->zero
