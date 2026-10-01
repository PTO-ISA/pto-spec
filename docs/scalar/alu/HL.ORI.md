<!-- GENERATED FROM: asl/scalar/alu/HL.ORI.asl -->
# HL.ORI

**Normative ASL source:** `asl/scalar/alu/HL.ORI.asl`

HL.ORI applies XLEN bitwise inclusive-or to SrcL and a sign-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ori-purpose role=purpose -->
## What HL.ORI does

`HL.ORI` is a 48-bit scalar ALU instruction that computes the bitwise inclusive-or of `SrcL` and a sign-extended 24-bit immediate, and publishes the XLEN result through one Reg5 destination.

The immediate is not a plain 24-bit mask. `SignExtend{PTO_XLEN}` copies its bit `23` into every higher bit of the operand, so a negative immediate reaches the or as `1` bits across the upper half.

<!-- PTO-READER-BLOCK: scalar-hl-ori-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_ORI`, which builds `right = SignExtend{PTO_XLEN}(immediate)` and returns `ScalarBinary(ScalarBinary_OR, left, right)`. Dispatch selects the same path with `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR, ScalarField_simm24, FALSE)`.

```asm
hl.ori SrcL, simm, ->{t, u, Rd}
```

Design point: sign extension makes the immediate a full XLEN mask built from 24 encoded bits. `simm24 = -8388608` sign-extends to `0xFFFFFFFFFF800000`, so the or sets bits `63:23` of the result even though the encoded field carries no information above bit `23`.

<!-- PTO-READER-BLOCK: scalar-hl-ori-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the XLEN result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the value to be combined.
- `simm24`, instruction slices `[36 +: 12]` and `[4 +: 12]`, supplies value bits `11:0` and `23:12`.

`SrcL` uses the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry. Encoded zero reads the architectural zero GPR, so `hl.ori zero, -1, ->a0` has no data dependency at all.

Design point: the 24-bit immediate is split into two 12-bit pieces that are not adjacent in the instruction, and the sign bit is instruction bit `47`, not bit `35`. A decoder that reads only the contiguous low piece gets a different number.

<!-- PTO-READER-BLOCK: scalar-hl-ori-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so an alias between `SrcL` and `RegDst` cannot feed a partially updated value back into the or.

The result is published through `RegDst`, then `TPC` advances by `6` bytes. `HL.ORI` accesses no memory and leaves numeric-status, reservation, descriptor, Tile, bundle, privilege and control-flow state unchanged; the only possible queue change is the `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-hl-ori-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes are assigned, all `32` `RegDst` codes are accepted, and every signed 24-bit value from `-8388608` through `8388607` is legal, so the operand pass can fail only on an unavailable temporary source. The two immediate pieces reconstruct one exact value; no encoding of the field is reserved.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: a bitwise or cannot overflow, so no arithmetic fault exists for any operand pair and the immediate range is the only bound the operation has.

<!-- PTO-READER-BLOCK: scalar-hl-ori-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL` held at the architectural zero GPR and `simm24 = -1`, the extended operand is `0xFFFFFFFFFFFFFFFF` and `RegDst` receives `0xFFFFFFFFFFFFFFFF`. With `SrcL = 0` and `simm24 = -8388608`, the extended operand is `0xFFFFFFFFFF800000`, so bits `63:23` of the published value are `1` and the rest are `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ori_48_c6d8ce28a78b | HL48 | 48 | 0x00003015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ori_48_c6d8ce28a78b | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ori_48_c6d8ce28a78b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ori_48_c6d8ce28a78b | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ori_48_c6d8ce28a78b | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_ori_48_c6d8ce28a78b | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_ori_48_c6d8ce28a78b | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ORI.asl -->
```asl
readonly func InstructionContractOperation_HL_ORI() => ScalarOperation
begin
    return ScalarOperation_HL_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ORI.asl -->
```asl
readonly func InstructionContractHandler_HL_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_ORI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ORI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_ORI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_OR,
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

- Sign-extend simm24 to PTO_XLEN, compute bitwise inclusive-or with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ORI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.ori a0, -1, ->a0
- hl.ori t#1, -8388608, ->u
- hl.ori zero, 8388607, ->zero
