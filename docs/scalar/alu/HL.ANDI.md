<!-- GENERATED FROM: asl/scalar/alu/HL.ANDI.asl -->
# HL.ANDI

**Normative ASL source:** `asl/scalar/alu/HL.ANDI.asl`

HL.ANDI applies XLEN bitwise conjunction to SrcL and a sign-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-andi-purpose role=purpose -->
## What HL.ANDI does

`HL.ANDI` is the 48-bit form of bitwise conjunction with a constant. It reads one Reg5 source, sign-extends the encoded `simm24` immediate to `PTO_XLEN`, and publishes the conjunction of the two values through `RegDst`. Successful execution advances `TPC` by `6` bytes.

Design point: the immediate is signed, so the extension fills every result bit above bit `23` with ones when `simm24` is negative and with zeros when it is not. That makes `hl.andi a0, -1, ->a0` an identity mask, while `hl.andi a0, 8388607, ->a0` clears every source bit from bit `23` upward.

<!-- PTO-READER-BLOCK: scalar-hl-andi-mechanism role=mechanism -->
## How the mask is formed

Decode rebuilds one exact `24`-bit value from the two 12-bit pieces at value bits `11:0` and `23:12`, then sign-extends bit `23` through bit `63`. The conjunction is bitwise, so each result bit depends only on the source bit and the mask bit at the same position.

Design point: a conjunction cannot overflow, so the only width effect here is the mask itself. When `simm24` is non-negative, mask bits `63:24` are zero and the result has no bit set above bit `23`. When `simm24` is negative, those mask bits are one, and the corresponding result bits repeat the source.

<!-- PTO-READER-BLOCK: scalar-hl-andi-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` reads one Reg5 value: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. A relative read leaves the named queue entry in place.
- `simm24` supplies the signed mask, `-8388608` through `8388607`.
- `RegDst` receives the conjunction: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: `simm24=0` is the numeric mask zero and not an omitted operand, so `hl.andi a0, 0, ->a0` writes `0` to `a0`. A caller who wants the source to pass through unchanged has to encode `-1`, because the mask `0` keeps nothing.

<!-- PTO-READER-BLOCK: scalar-hl-andi-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a repeated selector such as `hl.andi a0, -1, ->a0` still reads the pre-instruction `a0`. A `T` or `U` source is not consumed; only `RegDst=30` or `RegDst=31` changes a queue, by making the new value index `1` and discarding the entry that was at index `4`.

Publication is followed by the `TPC` advance of `6` bytes. `HL.ANDI` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-andi-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every signed `24`-bit two's-complement mask from `-8388608` through `8388607`.

Three rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Each precedes the destination effect and the `TPC` advance.

Design point: because the field is fully assigned, both extreme masks are ordinary encodings. `-8388608` keeps bits `63:23` and clears bits `22:0`, and `8388607` is its complement inside the low `24` bits. Neither extreme is reserved, and neither is a fault.

`HL.ANDI` adds no arithmetic exception: a conjunction has no overflow to discard.

<!-- PTO-READER-BLOCK: scalar-hl-andi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `18446744073709551615` and `simm24=8388607`, `hl.andi a0, 8388607, ->a0` publishes `8388607`. With `simm24=-8388608` the same source publishes `18446744073701163008`, and with `simm24=-1` it is republished unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_andi_48_fe11c7ebca41 | HL48 | 48 | 0x00002015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_andi_48_fe11c7ebca41 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_andi_48_fe11c7ebca41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_andi_48_fe11c7ebca41 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_andi_48_fe11c7ebca41 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_andi_48_fe11c7ebca41 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_andi_48_fe11c7ebca41 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDI.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDI.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_ANDI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ANDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ANDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_ANDI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
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

- Sign-extend simm24 to PTO_XLEN, compute bitwise conjunction with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ANDI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.andi a0, -1, ->a0
- hl.andi t#1, -8388608, ->u
- hl.andi zero, 8388607, ->zero
