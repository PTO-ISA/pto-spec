<!-- GENERATED FROM: asl/scalar/alu/HL.SUBI.asl -->
# HL.SUBI

**Normative ASL source:** `asl/scalar/alu/HL.SUBI.asl`

HL.SUBI applies XLEN subtraction to SrcL and a zero-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-SUBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-subi-purpose role=purpose -->
## What HL.SUBI does

`HL.SUBI` is a 48-bit scalar ALU instruction that subtracts a zero-extended 24-bit immediate from `SrcL` modulo `2^PTO_XLEN` and publishes the result through one Reg5 destination.

The immediate is unsigned. Every `uimm24` value is subtracted as a positive quantity in the range `0` through `16777215`.

<!-- PTO-READER-BLOCK: scalar-hl-subi-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_SUBI`, which builds `right = ZeroExtend{PTO_XLEN}(immediate)` and returns `ScalarBinary(ScalarBinary_SUB, left, right)`. Dispatch selects the same path with `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB, ScalarField_uimm24, FALSE)`.

```asm
hl.subi SrcL, uimm, ->{t, u, Rd}
```

Design point: the arithmetic and logical immediate spellings of this family differ in exactly this extension rule. `HL.SUBI` zero-extends its 24-bit field while `HL.ORI` and `HL.XORI` sign-extend theirs, so the same 24 encoded bits mean `16777215` under one mnemonic and `-1` under another.

<!-- PTO-READER-BLOCK: scalar-hl-subi-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the XLEN result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the value the immediate is subtracted from.
- `uimm24`, instruction slices `[36 +: 12]` and `[4 +: 12]`, supplies value bits `11:0` and `23:12`.

`SrcL` uses the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry. An encoded zero reads architectural GPR zero.

Design point: the two 12-bit pieces of the immediate sit at instruction bits `[47:36]` and `[15:4]`. They are not adjacent, and neither piece alone is the immediate; the decoder has to reassemble the 24-bit value before extending it.

<!-- PTO-READER-BLOCK: scalar-hl-subi-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so `hl.subi a0, 1, ->a0` decrements the pre-instruction `a0` and same-queue read-then-push cases publish the value read before the push.

The result is published through `RegDst`, and `TPC` then advances by `6` bytes. `HL.SUBI` reads and writes no memory and leaves numeric-status, reservation, descriptor, Tile, bundle, privilege and control-flow state unchanged; only the destination-selected queue push can change a temporary queue.

<!-- PTO-READER-BLOCK: scalar-hl-subi-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes and all `32` `RegDst` codes are assigned, and every unsigned 24-bit immediate from `0` through `16777215` is legal, so only an unavailable temporary source can fail the operand checks. Fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. A subtraction that underflows wraps and raises nothing.

Design point: because the field is unsigned, there is no negative-immediate spelling. Subtracting one and subtracting `16777215` are different encodings of the same field, and one instruction can only subtract a value from `0` through `16777215`.

<!-- PTO-READER-BLOCK: scalar-hl-subi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 3` and `uimm24 = 5`, the difference is `-2`, so `RegDst` receives `0xFFFFFFFFFFFFFFFE`. With `SrcL = 3` and `uimm24 = 16777215`, the difference is `-16777212` and `RegDst` receives `0xFFFFFFFFFF000004`. With `uimm24 = 0` the published value is `SrcL` unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.subi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_subi_48_e1f491a8aead | HL48 | 48 | 0x00001015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_subi_48_e1f491a8aead | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_subi_48_e1f491a8aead | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_subi_48_e1f491a8aead | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_subi_48_e1f491a8aead | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_subi_48_e1f491a8aead | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_subi_48_e1f491a8aead | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.SUBI.asl -->
```asl
readonly func InstructionContractOperation_HL_SUBI() => ScalarOperation
begin
    return ScalarOperation_HL_SUBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.SUBI.asl -->
```asl
readonly func InstructionContractHandler_HL_SUBI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_SUBI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_SUBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_SUBI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_SUBI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_SUB,
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

- Zero-extend uimm24 to PTO_XLEN, compute subtraction with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.SUBI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.subi a0, 1, ->a0
- hl.subi t#1, 16777215, ->u
- hl.subi zero, 0, ->zero
