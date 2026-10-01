<!-- GENERATED FROM: asl/scalar/alu/HL.MADDW.asl -->
# HL.MADDW

**Normative ASL source:** `asl/scalar/alu/HL.MADDW.asl`

HL.MADDW computes a signed 64-bit word multiply-add result and publishes its sign-extended low and high 32-bit halves.

## Normative identity {#PTO-INST-SCALAR-HL-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-maddw-purpose role=purpose -->
## What HL.MADDW does

`HL.MADDW` is a 48-bit scalar ALU instruction. It reads the low word of all three sources as signed values, forms the 64-bit accumulator `signed32(SrcL) * signed32(SrcR) + signed32(SrcD)`, and publishes its two 32-bit halves, each sign-extended to XLEN.

Both halves are published, so the destination pair carries the complete 64-bit accumulator: `RegDst0` gets `SignExtend(result[31:0])` and `RegDst1` gets `SignExtend(result[63:32])`.

<!-- PTO-READER-BLOCK: scalar-hl-maddw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_MADDW`, which sign-extends `addend[31:0]`, `left[31:0]` and `right[31:0]` to XLEN, takes the low `64` bits of `MultiplyWideSigned`, and adds the widened addend. Dispatch reaches the same 64-bit accumulator through `ExecuteScalarMultiplyAddPair` with `word_operation` true.

```asm
hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1
```

Design point: the word truncation happens before the multiply, not after it. With `SrcL = 0x100000000`, `SrcR = 2` and `SrcD = 0`, `HL.MADDW` publishes `0` in both halves because the low word of `SrcL` is `0`, while `HL.MADD` publishes `0x200000000`; no bit of a source above bit `31` can influence either `HL.MADDW` destination.

<!-- PTO-READER-BLOCK: scalar-hl-maddw-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0`, instruction slice `[23 +: 5]`, receives `SignExtend(result[31:0])`.
- `RegDst1`, instruction slice `[11 +: 5]`, receives `SignExtend(result[63:32])`.
- `SrcD`, instruction slice `[43 +: 5]`, supplies the addend word.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the left multiplicand word.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the right multiplicand word.

Sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming the entry. All three reads happen before either destination write.

Design point: because each half is sign-extended separately, a negative accumulator publishes `0xFFFFFFFFFFFFFFFF` in `RegDst1` rather than the raw high word. The high destination therefore holds a value in the same XLEN format as the low one, not an unsigned field.

<!-- PTO-READER-BLOCK: scalar-hl-maddw-effects role=effects -->
## Effects and ordering

The complete 64-bit accumulator is formed from source snapshots before the first destination write, so duplicate destination names and source-destination aliases all observe pre-instruction values.

Publication order is `RegDst0` then `RegDst1`. If both selectors name one GPR, the second high-word result is final; if both push one queue, `SignExtend(result[63:32])` is the newest entry and `SignExtend(result[31:0])` is next-newest.

After publication, `TPC` advances by `6` bytes. No memory is read or written, and no state outside `RegDst0`, `RegDst1` and `TPC` changes.

<!-- PTO-READER-BLOCK: scalar-hl-maddw-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding is assigned, and every `32`-code destination encoding is accepted, so only source availability can fail the operand checks. The fixed encoding bits must match the canonical 48-bit form; no operand value is otherwise reserved.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. An encoding that does not match the form raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination write, and `TPC` stays on the faulting instruction.

Design point: the accumulator is computed in `64` bits while both destinations are XLEN words. Both destinations use the destination map shared by the pair forms, so the discard and queue-push codes behave exactly as they do for the other pair forms even though the arithmetic is narrower.

<!-- PTO-READER-BLOCK: scalar-hl-maddw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = -3`, `SrcR = 5`, and `SrcD = 1`, the signed word product is `-15`, the result is `-14`, and `RegDst0` receives `SignExtend(0xFFFFFFF2)` = `0xFFFFFFFFFFFFFFF2` while `RegDst1` receives `SignExtend(0xFFFFFFFF)` = `0xFFFFFFFFFFFFFFFF`. With `SrcL = 70000`, `SrcR = 70000`, and `SrcD = 0`, the 64-bit result is `4900000000`, which is `0x124101100`, so `RegDst0` receives `605032704` and `RegDst1` receives `1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | HL48 | 48 | 0x00007047000e / 0x0600707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | 0–31 | none | none | sign-extended result[31:0] Reg5 destination | Encoded zero discards the low result. |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | 0–31 | none | none | sign-extended result[63:32] Reg5 destination | Encoded zero discards the high result. |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | sign-extended result[31:0] Reg5 destination |
| RegDst1 | sign-extended result[63:32] Reg5 destination |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractOperation_HL_MADDW() => ScalarOperation
begin
    return ScalarOperation_HL_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractHandler_HL_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
pure func InstructionContractResult_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    let effective_addend = SignExtend{PTO_XLEN}(addend[31:0]);
    let effective_left = SignExtend{PTO_XLEN}(left[31:0]);
    let effective_right = SignExtend{PTO_XLEN}(right[31:0]);
    let product = MultiplyWideSigned(effective_left, effective_right);
    return product[63:0] + effective_addend;
end;

pure func InstructionContractLow_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[31:0]);
end;

pure func InstructionContractHigh_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[63:32]);
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

- Interpret SrcD[31:0], SrcL[31:0], and SrcR[31:0] as signed two-complement values; compute signed32(SrcL) * signed32(SrcR) + signed32(SrcD) modulo 2^64.
- Snapshot every source and compute the complete 64-bit result before destinations. Publish SignExtend(result[31:0]) to RegDst0, then SignExtend(result[63:32]) to RegDst1.
- Duplicate destinations are legal and retain the second high-word result. No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish SignExtend(result[31:0]) to RegDst0, publish SignExtend(result[63:32]) to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.maddw srcl, srcr, srcd, ->dst0, dst1
