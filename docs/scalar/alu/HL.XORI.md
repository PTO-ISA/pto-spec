<!-- GENERATED FROM: asl/scalar/alu/HL.XORI.asl -->
# HL.XORI

**Normative ASL source:** `asl/scalar/alu/HL.XORI.asl`

HL.XORI applies XLEN bitwise exclusive-or to SrcL and a sign-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-XORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-xori-purpose role=purpose -->
## What HL.XORI does

`HL.XORI` is a 48-bit scalar ALU instruction that computes the bitwise exclusive-or of `SrcL` and a sign-extended 24-bit immediate and publishes the XLEN result through one Reg5 destination.

Because the operand is built by `SignExtend{PTO_XLEN}`, a negative immediate inverts the whole upper half as well as the bits it encodes directly.

<!-- PTO-READER-BLOCK: scalar-hl-xori-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_XORI`, which builds `right = SignExtend{PTO_XLEN}(immediate)` and returns `ScalarBinary(ScalarBinary_XOR, left, right)`. Dispatch selects the same path with `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR, ScalarField_simm24, FALSE)`.

```asm
hl.xori SrcL, simm, ->{t, u, Rd}
```

Design point: exclusive-or with a sign-extended field is a patterned complement, not just a local edit. `simm24 = -1` extends to `0xFFFFFFFFFFFFFFFF`, so `hl.xori a0, -1, ->a0` publishes the bitwise complement of the complete XLEN register.

<!-- PTO-READER-BLOCK: scalar-hl-xori-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the XLEN result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the value to be combined.
- `simm24`, instruction slices `[36 +: 12]` and `[4 +: 12]`, supplies value bits `11:0` and `23:12`.

`SrcL` uses the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming the entry. Encoded zero reads the architectural zero GPR.

Design point: the immediate is signed, so the field spans `-8388608` through `8388607` and each value inverts a different set of high bits. There is no unsigned reading of `simm24` and therefore no encoding that masks only the low bits without also touching the upper half when bit `23` is set.

<!-- PTO-READER-BLOCK: scalar-hl-xori-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so an alias between `SrcL` and `RegDst` cannot feed the newly published value back into the same instruction.

The result is published through `RegDst`, and `TPC` then advances by `6` bytes. `HL.XORI` reads and writes no memory and leaves numeric-status, reservation, descriptor, Tile, bundle, privilege and control-flow state unchanged; the only possible queue change is the destination-selected `T` or `U` push.

<!-- PTO-READER-BLOCK: scalar-hl-xori-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes and all `32` `RegDst` codes are assigned, and every signed 24-bit immediate is legal, so the operand pass can fail only on an unavailable temporary source. The fixed encoding bits must match the canonical 48-bit form; the two immediate pieces reconstruct one exact value and no encoding is reserved.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. The exclusive-or itself raises no exception.

Design point: a logical operation has no overflow corner, so the whole fault surface is the encoding match plus temporary source availability. Nothing about the operand values can move a fault from one of those two checks to the arithmetic.

<!-- PTO-READER-BLOCK: scalar-hl-xori-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0x0F` and `simm24 = -1`, the extended operand is `0xFFFFFFFFFFFFFFFF`, so `RegDst` receives `0xFFFFFFFFFFFFFFF0`. With `SrcL = 0` and `simm24 = 8388607`, the extended operand is `0x00000000007FFFFF` and `RegDst` receives `0x00000000007FFFFF`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.xori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_xori_48_b4d85f91aad8 | HL48 | 48 | 0x00004015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_xori_48_b4d85f91aad8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_xori_48_b4d85f91aad8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_xori_48_b4d85f91aad8 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_xori_48_b4d85f91aad8 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_xori_48_b4d85f91aad8 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_xori_48_b4d85f91aad8 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.XORI.asl -->
```asl
readonly func InstructionContractOperation_HL_XORI() => ScalarOperation
begin
    return ScalarOperation_HL_XORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.XORI.asl -->
```asl
readonly func InstructionContractHandler_HL_XORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_XORI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_XORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_XORI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_XORI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_XOR,
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

- Sign-extend simm24 to PTO_XLEN, compute bitwise exclusive-or with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.XORI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.xori a0, -1, ->a0
- hl.xori t#1, -8388608, ->u
- hl.xori zero, 8388607, ->zero
