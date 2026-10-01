<!-- GENERATED FROM: asl/scalar/alu/BIC.asl -->
# BIC

**Normative ASL source:** `asl/scalar/alu/BIC.asl`

BIC clears every bit in an independently selected wrapping scalar field and publishes the modified XLEN value.

## Normative identity {#PTO-INST-SCALAR-BIC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bic-purpose role=purpose -->
## What BIC does

`BIC` clears every bit of a selected bit field inside one Reg5 source and publishes the modified XLEN value through a Reg5 destination.

Design point: the field is described by two immediate values rather than by a mask, so the instruction performs a field-scoped clear in one step. A caller does not need a mask register, and the bits outside the field cannot be disturbed by the operation.

<!-- PTO-READER-BLOCK: scalar-bic-mechanism role=mechanism -->
## How the result is formed

- `imms` is the field start bit `M`, from `0` through `63`.
- `imml` encodes the field width `N` minus one, so raw values `0` through `63` select widths `1` through `64`.

The `N` bits beginning at bit `M` are written as `0`. Every bit outside the selected field keeps the value it had in the source.

Design point: `imml` stores `N - 1` so that the complete register width `64` is representable in six bits; encoded zero is a `1`-bit field, not an omitted field.

Design point: the field wraps. When `M + N` exceeds `64`, the field continues from bit `0`. The mechanism is a rotate of the source, a clear of the low `N` bits, and a rotate back, which is why `N=64` clears every bit regardless of `M`.

Design point: bits outside the field are preserved rather than re-derived. A field clear therefore never needs a second instruction to restore the untouched bits.

<!-- PTO-READER-BLOCK: scalar-bic-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `imml` and `imms` are immediate fields that describe the field; they read no storage.
- `RegDst` publishes the modified value: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so any clear of it publishes `0`. Encoded zero of `RegDst` discards the result rather than writing the zero GPR, so `bic a0, 0, 8, ->zero` is a legal encoding that changes no register.

<!-- PTO-READER-BLOCK: scalar-bic-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a destination that aliases the source still produces the cleared field computed from the pre-instruction value.

The result is published or discarded, and then `TPC` advances by `4` bytes. `BIC` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-bic-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every `imml` and `imms` value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: clearing bits has no exceptional outcome, so `BIC` raises no arithmetic, memory, alignment or permission fault. A clear that removes bits the program still needs is a programming error, not a trap.

<!-- PTO-READER-BLOCK: scalar-bic-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=4294967295`, `M=4` and `N=4`, the selected field is bits `4..7`, whose value is `240`; `bic a0, 4, 4, ->a1` publishes `4294967295 - 240 = 4294967055`. With `M=60` and `N=8` on the same source, the field wraps through bit `63` to bit `0` and both ends are cleared.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bic SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bic_32_3a10830a3a93 | L32 | 32 | 0x00002067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bic_32_3a10830a3a93 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bic_32_3a10830a3a93 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bic_32_3a10830a3a93 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bic_32_3a10830a3a93 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bic_32_3a10830a3a93 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bic_32_3a10830a3a93 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bic_32_3a10830a3a93 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bic_32_3a10830a3a93 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractOperation_BIC()
    => ScalarOperation
begin
    return ScalarOperation_BIC;
end;

pure func InstructionContractWidth_BIC(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BIC(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIC.asl -->
```asl
readonly func InstructionContractHandler_BIC()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;

pure func InstructionContractResult_BIC(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ModifyBitfield(
        value,
        width,
        offset,
        FALSE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- imms directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Clear the N selected source bits and preserve every unselected source bit.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or T/U destination push observes the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- BIC raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bic a0, 60, 8, ->a1
- bic t#1, 0, 64, ->u
